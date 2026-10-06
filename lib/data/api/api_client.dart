// HTTP transport for the needy API (Django/DRF).
//
// Responsibilities: base URL resolution (--dart-define), JWT attach +
// refresh, JSON encoding, single typed error. Domain logic lives in
// [ApiBackend]; model mapping lives in [api_dto.dart].
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Server failure surfaced to the UI layer.
class ApiError implements Exception {
  ApiError(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  /// Machine-readable error code from the {detail, code} envelope.
  String? code;

  bool get isAuthError => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}

/// Where the API lives. Set NEEDY_API_URL when building:
///
///   flutter build apk --release --dart-define=NEEDY_API_URL=https://your-api.onrender.com
const String _kDefinedApiUrl = String.fromEnvironment('NEEDY_API_URL');
const String _kLegacyApiUrl = String.fromEnvironment('NUVRA_API_URL');
String kDefaultApiUrl = () {
  final defined = String.fromEnvironment('NEEDY_API_URL');
  final legacy = String.fromEnvironment('NUVRA_API_URL');
  if (defined.isNotEmpty) return defined;
  if (legacy.isNotEmpty) return legacy;
  return 'http://10.0.2.2:8000'; // Android emulator -> host machine
}();

class ApiClient {
  ApiClient({String? baseUrl}) : base = Uri.parse(baseUrl ?? kDefaultApiUrl);

  final Uri base;
  http.Client? _inner;
  String? _access;
  String? _refresh;

  static const _kAccess = 'needy_access';
  static const _kRefresh = 'needy_refresh';

  bool get hasToken => _access != null;

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _access = prefs.getString(_kAccess);
    _refresh = prefs.getString(_kRefresh);
  }

  Future<void> saveTokens({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, access);
    await prefs.setString(_kRefresh, refresh);
  }

  Future<void> clearTokens() async {
    _access = null;
    _refresh = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
  }

  http.Client get _client => _inner ??= http.Client();

  Uri _u(String path, [Map<String, String>? query]) {
    final uri = base.replace(path: base.path.endsWith('/') && path.startsWith('/')
        ? base.path + path.substring(1)
        : base.path + path);
    return query == null || query.isEmpty
        ? uri
        : uri.replace(queryParameters: {
            ...uri.queryParameters,
            ...query,
          });
  }

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (_access != null) 'Authorization': 'Bearer $_access',
      };

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send('POST', path, body: body);

  Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _send('PATCH', path, body: body);

  /// Multipart image upload → stored file's absolute URL. Mirrors [_send]'s
  /// one transparent refresh attempt on 401.
  Future<String> upload(
    String path,
    Uint8List bytes, {
    required String filename,
    required String mimeType,
  }) async {
    Future<http.Response> send() async {
      final req = http.MultipartRequest('POST', _u(path, null));
      if (_access != null) req.headers['Authorization'] = 'Bearer $_access';
      // No explicit part content-type needed — the server sniffs magic
      // bytes, so [mimeType] is only used by demo mode's data URL.
      req.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );
      return _client.send(req).then(http.Response.fromStream);
    }

    try {
      var response = await send();
      if (response.statusCode == 401 && _refresh != null) {
        if (await _tryRefresh()) response = await send();
      }
      final data = _handle(response) as Map<String, dynamic>;
      return data['url'] as String;
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError('Upload failed — is the server reachable?');
    }
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    try {
      var response = await _client
          .send(http.Request(method, _u(path, query))
            ..headers.addAll(_headers())
            ..body = body == null ? '' : jsonEncode(body))
          .then(http.Response.fromStream);

      // One transparent refresh attempt on 401.
      if (response.statusCode == 401 && _refresh != null) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await _client
              .send(http.Request(method, _u(path, query))
                ..headers.addAll(_headers())
                ..body = body == null ? '' : jsonEncode(body))
              .then(http.Response.fromStream);
        }
      }

      return _handle(response);
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError('Network error — is the server reachable?');
    }
  }

  Future<bool> _tryRefresh() async {
    try {
      final response = await _client.post(
        _u('/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refresh}),
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await saveTokens(
        access: data['access'] as String,
        refresh: (data['refresh'] ?? _refresh) as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _handle(http.Response response) {
    dynamic decoded;
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('json') && response.body.isNotEmpty) {
      decoded = jsonDecode(response.body);
    }
    if (response.statusCode >= 400) {
      String message = 'Request failed (${response.statusCode})';
      if (decoded is Map) {
        message = (decoded['detail'] as String?) ?? message;
      }
      final err = ApiError(message, statusCode: response.statusCode);
      if (decoded is Map && decoded['code'] is String) {
        err.code = decoded['code'] as String;
      }
      throw err;
    }
    return decoded;
  }

  /// Quick reachability probe used to decide demo-mode fallback.
  Future<bool> ping() async {
    try {
      final response = await _client
          .get(_u('/api/v1/health'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void debugPrintTokens() {
    if (kDebugMode) debugPrint('needy api: access=${_access != null}');
  }
}
