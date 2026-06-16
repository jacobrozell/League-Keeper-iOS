#!/usr/bin/env python3
"""Generate App Icon, CrestLogo, and static launch-screen assets.

Source of truth for crest artwork: Scripts/assets/crest-mark.png (transparent PNG).
On first run, that file is extracted from legacy CrestLogo/AppIcon rasters if missing.

Regenerate everything:
    python3 Scripts/generate-launch-assets.py
"""

from __future__ import annotations

import json
import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "Assets.xcassets"
APP_ICON = ASSETS / "AppIcon.appiconset" / "AppIcon-1024.png"
CREST_DIR = ASSETS / "CrestLogo.imageset"
CREST_SOURCE = ROOT / "Scripts" / "assets" / "crest-mark.png"
APP_ICON_PALETTE = "dark"

PALETTES = {
    "light": {
        "bg": (0xF4, 0xF1, 0xEA),
        "bg2": (0xEB, 0xE6, 0xDC),
        "gold": (0x9A, 0x74, 0x28),
        "blood": (0xA8, 0x32, 0x28),
    },
    "dark": {
        "bg": (0x0B, 0x0C, 0x0F),
        "bg2": (0x10, 0x12, 0x18),
        "gold": (0xC9, 0xA4, 0x4C),
        "blood": (0x8C, 0x2B, 0x22),
    },
}

SIZES = {
    "1x": (393, 852),
    "2x": (786, 1704),
    "3x": (1179, 2556),
}

CREST_SIZES = {"1x": 180, "2x": 360, "3x": 540}


def blend(bottom: tuple[int, int, int], top: tuple[int, int, int], alpha: float) -> tuple[int, int, int]:
    return tuple(int(bottom[i] * (1 - alpha) + top[i] * alpha) for i in range(3))


def radial_gradient(
    size: tuple[int, int],
    center: tuple[float, float],
    inner: float,
    outer: float,
    color: tuple[int, int, int],
    alpha: float,
) -> Image.Image:
    width, height = size
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    pixels = layer.load()
    cx = center[0] * width
    cy = center[1] * height
    for y in range(height):
        for x in range(width):
            distance = math.hypot(x - cx, y - cy)
            if distance > outer:
                continue
            if distance <= inner:
                factor = 1.0
            else:
                factor = 1.0 - (distance - inner) / (outer - inner)
            pixels[x, y] = (*color, int(255 * alpha * factor))
    return layer


def make_backdrop(size: tuple[int, int], palette: dict[str, tuple[int, int, int]]) -> Image.Image:
    width, height = size
    base = Image.new("RGB", size, palette["bg"])
    canvas = base.convert("RGBA")

    top_glow = radial_gradient(size, (0.5, 0.0), 20, 420, palette["gold"], 0.18)
    bottom_glow = radial_gradient(size, (1.0, 1.0), 10, 320, palette["blood"], 0.08)

    canvas = Image.alpha_composite(canvas, top_glow)
    canvas = Image.alpha_composite(canvas, bottom_glow)

    fade = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(fade)
    mid = int(height * 0.45)
    for y in range(mid, height):
        t = (y - mid) / max(height - mid, 1)
        color = blend(palette["bg"], palette["bg2"], 0.55 * t)
        draw.line([(0, y), (width, y)], fill=(*color, 255))
    canvas = Image.alpha_composite(canvas, fade)
    return canvas.convert("RGB")


def make_crest_hero(diameter: int, palette: dict[str, tuple[int, int, int]], crest: Image.Image) -> Image.Image:
    canvas = int(diameter)
    size = (canvas, canvas)
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    gold = palette["gold"]
    center = canvas / 2
    crest_size = int(canvas * 0.68)

    outer = canvas * 0.59
    middle = canvas * 0.50
    inner_fill = canvas * 0.50

    draw.ellipse(
        (center - outer, center - outer, center + outer, center + outer),
        outline=(*gold, int(255 * 0.12)),
        width=max(4, int(canvas * 0.05)),
    )
    draw.ellipse(
        (center - inner_fill, center - inner_fill, center + inner_fill, center + inner_fill),
        fill=(*gold, int(255 * 0.12)),
    )
    draw.ellipse(
        (center - middle, center - middle, center + middle, center + middle),
        outline=(*gold, int(255 * 0.35)),
        width=max(2, int(canvas * 0.011)),
    )

    crest_resized = crest.resize((crest_size, crest_size), Image.Resampling.LANCZOS)
    offset = int((canvas - crest_size) / 2)
    image.alpha_composite(crest_resized, (offset, offset))
    return image


def write_imageset(
    name: str,
    *,
    appearances: dict[str, dict[str, str]],
) -> None:
    imageset = ASSETS / f"{name}.imageset"
    imageset.mkdir(parents=True, exist_ok=True)

    images: list[dict] = []
    for appearance, scales in appearances.items():
        for scale, filename in scales.items():
            entry = {
                "filename": filename,
                "idiom": "universal",
                "scale": scale,
            }
            if appearance != "default":
                entry["appearances"] = [
                    {"appearance": "luminosity", "value": appearance}
                ]
            images.append(entry)

    contents = {"images": images, "info": {"author": "xcode", "version": 1}}
    (imageset / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def write_color(name: str, light: str, dark: str) -> None:
    colorset = ASSETS / f"{name}.colorset"
    colorset.mkdir(parents=True, exist_ok=True)

    def components(hex_value: str) -> dict[str, str]:
        value = hex_value.lstrip("#")
        r = int(value[0:2], 16) / 255
        g = int(value[2:4], 16) / 255
        b = int(value[4:6], 16) / 255
        return {"alpha": "1.000", "red": f"{r:.3f}", "green": f"{g:.3f}", "blue": f"{b:.3f}"}

    contents = {
        "colors": [
            {
                "color": {"color-space": "srgb", "components": components(light)},
                "idiom": "universal",
            },
            {
                "appearances": [{"appearance": "luminosity", "value": "dark"}],
                "color": {"color-space": "srgb", "components": components(dark)},
                "idiom": "universal",
            },
        ],
        "info": {"author": "xcode", "version": 1},
    }
    (colorset / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def make_app_icon(crest: Image.Image, palette: dict[str, tuple[int, int, int]]) -> Image.Image:
    """1024×1024 App Store icon — dark brand field with centered circular crest hero."""
    size = 1024
    base = Image.new("RGB", (size, size), palette["bg"])
    hero_diameter = int(size * 0.82)
    hero = make_crest_hero(hero_diameter, palette, crest)
    offset = int((size - hero_diameter) / 2)
    composed = base.convert("RGBA")
    composed.alpha_composite(hero, (offset, offset))
    return composed.convert("RGB")


def make_crest_logo_image(
    edge: int,
    palette: dict[str, tuple[int, int, int]],
    crest: Image.Image,
) -> Image.Image:
    """Square CrestLogo raster — dark field with circular hero mark for in-app UI."""
    base = Image.new("RGB", (edge, edge), palette["bg"])
    hero_diameter = int(edge * 0.92)
    hero = make_crest_hero(hero_diameter, palette, crest)
    offset = int((edge - hero_diameter) / 2)
    composed = base.convert("RGBA")
    composed.alpha_composite(hero, (offset, offset))
    return composed.convert("RGB")


def color_saturation(red: int, green: int, blue: int) -> float:
    peak = max(red, green, blue)
    floor = min(red, green, blue)
    if peak == 0:
        return 0.0
    return (peak - floor) / peak


def clean_crest_artwork(image: Image.Image) -> Image.Image:
    """Drop neutral frame pixels left from the legacy square crest raster."""
    cleaned = image.convert("RGBA").copy()
    pixels = cleaned.load()
    width, height = cleaned.size

    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = pixels[x, y]
            if alpha < 10:
                continue

            spread = max(red, green, blue) - min(red, green, blue)
            luminance = (red + green + blue) / 3
            saturation = color_saturation(red, green, blue)
            is_artwork = (
                saturation > 0.18
                or (red > 170 and green > 120 and blue < 130)  # gold trophy / diamonds
                or (green > 90 and blue > 90 and red < 120)  # teal cards
                or (max(red, green, blue) < 50 and alpha > 200)  # dark linework
            )
            is_legacy_frame = spread < 35 and 55 < luminance < 140

            if not is_artwork or is_legacy_frame:
                pixels[x, y] = (0, 0, 0, 0)

    return cleaned


def extract_crest_source(image: Image.Image) -> Image.Image:
    """Isolate transparent crest artwork from a legacy composed raster."""
    im = image.convert("RGBA")
    width, height = im.size
    crest_size = int(min(width, height) * 0.68)
    left = (width - crest_size) // 2
    top = (height - crest_size) // 2
    cropped = im.crop((left, top, left + crest_size, top + crest_size)).copy()
    pixels = cropped.load()
    for y in range(crest_size):
        for x in range(crest_size):
            red, green, blue, _alpha = pixels[x, y]
            if red > 215 and green > 210 and blue > 195:
                pixels[x, y] = (0, 0, 0, 0)
            elif red > 190 and green > 160 and blue > 120 and red >= green >= blue:
                pixels[x, y] = (0, 0, 0, 0)
            elif max(red, green, blue) < 60:
                pixels[x, y] = (0, 0, 0, 0)
    return clean_crest_artwork(cropped)


def load_legacy_composed_raster() -> Image.Image | None:
    """Load an older composed crest/app icon raster for one-time extraction."""
    crest_path = CREST_DIR / "CrestLogo@3x.png"
    if crest_path.exists():
        return Image.open(crest_path).convert("RGBA")
    if APP_ICON.exists():
        return Image.open(APP_ICON).convert("RGBA")
    return None


def load_crest_source() -> Image.Image:
    """Load transparent crest artwork used by hero, app icon, and CrestLogo."""
    if CREST_SOURCE.exists():
        crest = Image.open(CREST_SOURCE).convert("RGBA")
    else:
        legacy = load_legacy_composed_raster()
        if legacy is None:
            raise FileNotFoundError(
                f"Need {CREST_SOURCE} or a legacy CrestLogo/AppIcon raster to extract crest artwork"
            )
        crest = extract_crest_source(legacy)

    crest = clean_crest_artwork(crest)
    CREST_SOURCE.parent.mkdir(parents=True, exist_ok=True)
    crest.save(CREST_SOURCE, format="PNG", optimize=True)
    return crest


def ensure_app_icon(crest: Image.Image) -> Image.Image:
    """Write AppIcon-1024.png from crest artwork and the brand icon palette."""
    APP_ICON.parent.mkdir(parents=True, exist_ok=True)
    palette = PALETTES[APP_ICON_PALETTE]
    icon = make_app_icon(crest, palette)
    icon.save(APP_ICON, format="PNG", optimize=True)
    return icon


def write_crest_logo(crest: Image.Image) -> None:
    """Build CrestLogo.imageset — circular hero mark, not a shrunken app icon."""
    palette = PALETTES[APP_ICON_PALETTE]
    CREST_DIR.mkdir(parents=True, exist_ok=True)

    filenames: dict[str, str] = {}
    for scale, edge in CREST_SIZES.items():
        filename = "CrestLogo.png" if scale == "1x" else f"CrestLogo@{scale}.png"
        image = make_crest_logo_image(edge, palette, crest)
        image.save(CREST_DIR / filename, format="PNG", optimize=True)
        filenames[scale] = filename

    contents = {
        "images": [
            {"filename": filenames[scale], "idiom": "universal", "scale": scale}
            for scale in ("1x", "2x", "3x")
        ],
        "info": {"author": "xcode", "version": 1},
    }
    (CREST_DIR / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def main() -> None:
    crest_source = load_crest_source()
    ensure_app_icon(crest_source)
    write_crest_logo(crest_source)

    backdrop_appearances: dict[str, dict[str, str]] = {"default": {}, "dark": {}}
    for scale, size in SIZES.items():
        for mode, palette in PALETTES.items():
            suffix = "" if mode == "light" else f"-{mode}"
            filename = f"LaunchBackdrop{suffix}@{scale}.png"
            image = make_backdrop(size, palette)
            path = ASSETS / "LaunchBackdrop.imageset" / filename
            path.parent.mkdir(parents=True, exist_ok=True)
            image.save(path, format="PNG", optimize=True)
            if mode == "light":
                backdrop_appearances["default"][scale] = filename
            else:
                backdrop_appearances["dark"][scale] = filename

    write_imageset("LaunchBackdrop", appearances=backdrop_appearances)

    crest_appearances: dict[str, dict[str, str]] = {"default": {}, "dark": {}}
    crest_diameters = {"1x": 132, "2x": 264, "3x": 396}

    for scale, diameter in crest_diameters.items():
        for mode, palette in PALETTES.items():
            suffix = "" if mode == "light" else f"-{mode}"
            filename = f"LaunchCrestHero{suffix}@{scale}.png"
            image = make_crest_hero(diameter, palette, crest_source)
            path = ASSETS / "LaunchCrestHero.imageset" / filename
            path.parent.mkdir(parents=True, exist_ok=True)
            image.save(path, format="PNG", optimize=True)
            if mode == "light":
                crest_appearances["default"][scale] = filename
            else:
                crest_appearances["dark"][scale] = filename

    write_imageset("LaunchCrestHero", appearances=crest_appearances)

    write_color("BrandGold", "#9a7428", "#c9a44c")
    write_color("BrandInk", "#1a1814", "#e8e5dc")
    write_color("BrandInkSecondary", "#5c574e", "#9a978c")

    print("Generated launch assets in", ASSETS)


if __name__ == "__main__":
    main()
