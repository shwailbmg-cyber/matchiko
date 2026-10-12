"""Draws the app icon (logo mark on the brand background) for Android,
iOS and web. Run from app/: python3 tool/make_icons.py (needs Pillow).
Same shapes as lib/core/widgets/logo_mark.dart (40x40 viewBox)."""
import json
import os

from PIL import Image, ImageDraw

BG_TOP = (36, 16, 86)     # MkColors.heroDeep
BG_BOTTOM = (11, 10, 26)  # MkColors.bg
MARK = (157, 107, 255)    # MkColors.primary
S = 4096                  # draw big, scale down (anti-aliasing)


def icon(mark_share: float) -> Image.Image:
    img = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(img)
    for y in range(S):  # vertical gradient
        t = y / (S - 1)
        d.line([(0, y), (S, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)))
    k = S * mark_share / 40  # viewBox unit in pixels
    o = (S - 40 * k) / 2

    def p(x, y):
        return (o + x * k, o + y * k)

    # Two rounded squares, the second turned 45° around the centre.
    layer = Image.new("L", (S, S))
    ImageDraw.Draw(layer).rounded_rectangle([p(8, 8), p(32, 32)], radius=2.5 * k, fill=255)
    both = Image.composite(Image.new("L", (S, S), 255), layer.rotate(45, resample=Image.BICUBIC), layer)
    img.paste(MARK, mask=both)
    d.ellipse([p(20 - 8.6, 20 - 8.6), p(20 + 8.6, 20 + 8.6)], fill=BG_BOTTOM)
    ball = [p(20, 14.6), p(25.1, 18.3), p(23.1, 24.3), p(16.9, 24.3), p(14.9, 18.3)]
    d.line(ball + [ball[0], ball[1]], fill=MARK, width=round(1.5 * k), joint="curve")
    return img


def save(img: Image.Image, path: str, px: int) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.resize((px, px), Image.LANCZOS).save(path, optimize=True)


full = icon(0.70)   # launcher icons
safe = icon(0.56)   # maskable / adaptive: keep the mark in the safe zone

for name, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    save(full, f"android/app/src/main/res/mipmap-{name}/ic_launcher.png", px)

ios = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
for entry in json.load(open(f"{ios}/Contents.json"))["images"]:
    size = float(entry["size"].split("x")[0])
    scale = int(entry["scale"].rstrip("x"))
    save(full, f"{ios}/{entry['filename']}", round(size * scale))

save(full, "web/favicon.png", 32)
save(full, "web/icons/Icon-192.png", 192)
save(full, "web/icons/Icon-512.png", 512)
save(safe, "web/icons/Icon-maskable-192.png", 192)
save(safe, "web/icons/Icon-maskable-512.png", 512)
