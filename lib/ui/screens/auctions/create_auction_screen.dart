import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/haptics.dart';
import '../../../state/providers.dart';
import '../../widgets/common.dart';

class CreateAuctionScreen extends ConsumerStatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  ConsumerState<CreateAuctionScreen> createState() =>
      _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends ConsumerState<CreateAuctionScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _buyNowPriceController = TextEditingController();
  final _areaController = TextEditingController(text: 'Madiwala 5th Block');

  String _selectedCategory = 'Home & Room';
  int _selectedDurationHours = 24;

  Uint8List? _photoBytes;
  String _photoName = 'photo.jpg';
  String _photoMime = 'image/jpeg';
  bool _publishing = false;

  final List<String> _categories = [
    'Time & Service',
    'Gadgets',
    'Home & Room',
    'Fashion & Wear',
    'Experiences',
  ];

  final List<int> _durations = [1, 6, 12, 24, 48];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    _buyNowPriceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Host an Auction',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: UniformBackButton.dark(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verified Badge Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verified Seller Mode Active · Anyone can bid on your time or item listing.',
                      style: TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Product Photo
            _label('Product Photo'),
            _photoSection(),
            const SizedBox(height: 24),

            // Item/Service Title
            _label('Auction Item or Service Title'),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDeco('e.g. PS5 Console, 2hr Coding Help, Sofa'),
            ),
            const SizedBox(height: 24),

            // Category Selection
            _label('Category'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSel = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSel ? Colors.white : Colors.white60,
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFF8B5CF6),
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSel ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Description
            _label('Description'),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDeco('Detail condition, time slot details, or specs...'),
            ),
            const SizedBox(height: 24),

            // Pricing Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Base Starting Price (₹)'),
                      TextField(
                        controller: _basePriceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _inputDeco('500'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Instant Buy Price (Optional)'),
                      TextField(
                        controller: _buyNowPriceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: _inputDeco('1500'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Duration
            _label('Auction Running Duration'),
            Row(
              children: _durations.map((hrs) {
                final isSel = hrs == _selectedDurationHours;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    height: 42,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSel ? const Color(0xFF8B5CF6) : const Color(0xFF1E293B),
                        side: BorderSide(color: isSel ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.1)),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => setState(() => _selectedDurationHours = hrs),
                      child: Text(
                        '${hrs}h',
                        style: TextStyle(
                          color: isSel ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Location / Area
            _label('Meeting / Pickup Area'),
            TextField(
              controller: _areaController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDeco('Madiwala · 5th Block'),
            ),
            const SizedBox(height: 24),

            // Platform Fee Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_outlined, color: Color(0xFFF472B6), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Standard 5% platform service fee is deducted only when auction completes successfully.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Publish Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _publishing ? null : _publish,
                child: const Text(
                  'Publish Live Auction',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final basePrice = double.tryParse(_basePriceController.text.trim()) ?? 100;
    final buyNow = double.tryParse(_buyNowPriceController.text.trim());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an auction title')),
      );
      return;
    }

    setState(() => _publishing = true);

    // Photo first, so a failed upload keeps the form open.
    var imageUrl = '';
    if (_photoBytes != null) {
      try {
        imageUrl = await ref.read(storeProvider).backend.uploadImage(
              _photoBytes!,
              filename: _photoName,
              mimeType: _photoMime,
            );
      } catch (e) {
        if (!mounted) return;
        setState(() => _publishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo upload failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        return;
      }
    }

    AppHaptics.heavy();
    ref.read(storeProvider).backend.createAuction(
          title: title,
          description: desc.isEmpty ? 'Verified auction listing.' : desc,
          category: _selectedCategory,
          imageUrl: imageUrl,
          basePrice: basePrice,
          buyItNowPrice: buyNow,
          durationHours: _selectedDurationHours,
          area: _areaController.text,
        );

    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auction published and live!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photoBytes = bytes;
      _photoName = x.name;
      _photoMime = x.mimeType ??
          (x.name.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');
    });
  }

  Widget _photoSection() {
    return _photoBytes == null
        ? GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      color: Color(0xFF8B5CF6), size: 34),
                  SizedBox(height: 8),
                  Text(
                    'Add a product photo — listings with photos bid faster',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        : Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  _photoBytes!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _photoChip(Icons.refresh_rounded, 'Change', _pickPhoto),
                    const SizedBox(width: 6),
                    _photoChip(Icons.close_rounded, 'Remove', () {
                      setState(() => _photoBytes = null);
                    }),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _photoChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
