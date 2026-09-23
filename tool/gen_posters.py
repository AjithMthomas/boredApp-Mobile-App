# Generates hub hero posters (767x383 ~ 2:1) for the internal pages.
# Poster style: deep diagonal gradient + layered translucent circles +
# fine grid dots + soft glow blobs — abstract "poster" backgrounds that
# carry the app's aurora language. Copy (title etc.) is rendered by Flutter
# on top, so text stays crisp and localizable.
import struct, zlib, os, math, random

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'posters')
os.makedirs(OUT, exist_ok=True)

W, H = 767, 383

def write_png(path, w, h, pixel_fn):
    raw = b''
    for y in range(h):
        raw += b'\x00'
        for x in range(w):
            r, g, b = pixel_fn(x, y)
            raw += bytes((clamp(r), clamp(g), clamp(b)))
    def chunk(tag, data):
        c = struct.pack('>I', len(data)) + tag + data
        return c + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)
    png = (b'\x89PNG\r\n\x1a\n'
           + chunk(b'IHDR', ihdr)
           + chunk(b'IDAT', zlib.compress(raw, 9))
           + chunk(b'IEND', b''))
    open(path, 'wb').write(png)
    print('wrote', path, w, 'x', h)

def clamp(v):
    return max(0, min(255, int(v)))

def lerp(a, b, t):
    return a + (b - a) * t

def mix(c1, c2, t):
    return (lerp(c1[0], c2[0], t), lerp(c1[1], c2[1], t), lerp(c1[2], c2[2], t))

def base_gradient(x, y, c_top_left, c_bottom_right):
    t = (x / W + y / H) / 2
    return mix(c_top_left, c_bottom_right, t)

def circle_layer(x, y, cx, cy, radius, tint, strength):
    d = math.hypot(x - cx, y - cy)
    if d >= radius:
        return 0.0
    # soft edge falloff
    t = 1 - (d / radius)
    return strength * (t ** 0.8)

def dot_grid(x, y, gap, dot_r, tint, alpha):
    gx, gy = x % gap - gap / 2, y % gap - gap / 2
    d = math.hypot(gx, gy)
    if d < dot_r:
        return alpha * (1 - d / dot_r)
    return 0.0

def add(base, overlay):
    return tuple(base[i] + overlay[i] for i in range(3))

POSTERS = {
    # deep crimson → rose (emergency)
    'poster_emergency.png': ((127, 29, 58), (225, 29, 72), [
        # glow blobs
        ((620, 90), 190, (255, 190, 205), 0.35),
        ((680, 300), 150, (255, 120, 150), 0.30),
        # big soft rings (radar motif)
        ((640, 170), 240, (255, 255, 255), 0.05),
        ((640, 170), 170, (255, 255, 255), 0.06),
        ((640, 170), 105, (255, 255, 255), 0.08),
        # core pulse dot
        ((640, 170), 42, (255, 230, 238), 0.9),
    ]),
    # deep amber → gold (shop gigs)
    'poster_gigs.png': ((146, 64, 14), (245, 158, 11), [
        ((630, 100), 180, (255, 225, 170), 0.35),
        ((690, 290), 140, (255, 190, 110), 0.30),
        # storefront awning arcs
        ((620, 210), 230, (255, 255, 255), 0.05),
        ((620, 210), 160, (255, 255, 255), 0.07),
        ((620, 210), 95, (255, 255, 255), 0.09),
        ((620, 210), 40, (255, 243, 214), 0.9),
    ]),
    # deep violet → lilac (rooms)
    'poster_rooms.png': ((76, 29, 149), (139, 92, 246), [
        ((620, 110), 185, (216, 200, 255), 0.35),
        ((680, 300), 145, (180, 150, 250), 0.30),
        ((630, 190), 235, (255, 255, 255), 0.05),
        ((630, 190), 165, (255, 255, 255), 0.06),
        ((630, 190), 100, (255, 255, 255), 0.08),
        ((630, 190), 42, (238, 230, 255), 0.9),
    ]),
    # deep emerald → mint (teams)
    'poster_team.png': ((6, 78, 59), (52, 211, 153), [
        ((620, 100), 185, (190, 245, 220), 0.35),
        ((690, 295), 145, (120, 230, 190), 0.30),
        ((635, 185), 235, (255, 255, 255), 0.05),
        ((635, 185), 165, (255, 255, 255), 0.06),
        ((635, 185), 100, (255, 255, 255), 0.08),
        ((635, 185), 42, (220, 255, 240), 0.9),
    ]),
}

GAP, DOT_R = 26, 2.2

for name, (c1, c2, layers) in POSTERS.items():
    def px(x, y, c1=c1, c2=c2, layers=layers):
        col = base_gradient(x, y, c1, c2)
        for (cx, cy), r, tint, s in layers:
            a = circle_layer(x, y, cx, cy, r, tint, s)
            if a > 0:
                col = mix(col, tint, min(1.0, a))
        # subtle dot grid for print-poster texture
        d = dot_grid(x, y, GAP, DOT_R, (255, 255, 255), 0.10)
        if d > 0:
            col = mix(col, (255, 255, 255), d)
        # left-side scrim so white text stays readable
        if x < 300:
            col = mix(col, c1, 0.35 * (1 - x / 300))
        return col
    write_png(os.path.join(OUT, name), W, H, px)

print('done')
