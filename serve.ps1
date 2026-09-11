# Minimal static file server for the Flutter web build (localhost only).
$prefix = 'http://127.0.0.1:8090/'
$root = 'D:\MyFuture\bored app\time_need_app\build\web'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Output "Serving $root at $prefix"

$mimes = @{
  '.html' = 'text/html'; '.js' = 'application/javascript';
  '.css' = 'text/css'; '.png' = 'image/png'; '.jpg' = 'image/jpeg';
  '.svg' = 'image/svg+xml'; '.ico' = 'image/x-icon';
  '.json' = 'application/json'; '.wasm' = 'application/wasm';
  '.ttf' = 'font/ttf'; '.woff' = 'font/woff'; '.woff2' = 'font/woff2';
  '.map' = 'application/json'
}

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $path = $ctx.Request.Url.AbsolutePath
  if ($path -eq '/') { $path = '/index.html' }
  $file = Join-Path $root ($path -replace '/', '\')
  if (Test-Path $file -PathType Leaf) {
    $ext = [System.IO.Path]::GetExtension($file).ToLowerInvariant()
    $type = if ($mimes.ContainsKey($ext)) { $mimes[$ext] } else { 'application/octet-stream' }
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $ctx.Response.ContentType = $type
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    # SPA fallback to index.html
    $file = Join-Path $root 'index.html'
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $ctx.Response.ContentType = 'text/html'
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  }
  $ctx.Response.Close()
}
