#!/usr/bin/env bash
# generate-sizes.sh — генерирует все размеры логотипа из assets/saqta-logo.png
#
# Требует: sips (входит в macOS) или ImageMagick.
# Использование:
#   bash assets/generate-sizes.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGINAL="$SCRIPT_DIR/saqta-logo.png"

if [ ! -f "$ORIGINAL" ]; then
    echo "✗ Не найден: $ORIGINAL"
    echo ""
    echo "Положи оригинал логотипа (1024×1024 PNG) сюда:"
    echo "  $ORIGINAL"
    exit 1
fi

# Используем sips на macOS, ImageMagick везде
if command -v sips >/dev/null 2>&1; then
    RESIZE() {
        local out="$1"
        local size="$2"
        cp "$ORIGINAL" "$out"
        sips -Z "$size" "$out" >/dev/null
    }
elif command -v magick >/dev/null 2>&1; then
    RESIZE() {
        local out="$1"
        local size="$2"
        magick "$ORIGINAL" -resize "${size}x${size}" "$out"
    }
elif command -v convert >/dev/null 2>&1; then
    RESIZE() {
        local out="$1"
        local size="$2"
        convert "$ORIGINAL" -resize "${size}x${size}" "$out"
    }
else
    echo "✗ Нужен sips (macOS) или ImageMagick:"
    echo "    brew install imagemagick"
    exit 1
fi

echo "→ Генерю размеры из $ORIGINAL"
RESIZE "$SCRIPT_DIR/saqta-logo-512.png" 512
RESIZE "$SCRIPT_DIR/saqta-logo-256.png" 256
RESIZE "$SCRIPT_DIR/saqta-logo-128.png" 128
RESIZE "$SCRIPT_DIR/saqta-logo-64.png"  64
RESIZE "$SCRIPT_DIR/saqta-logo-32.png"  32

echo ""
echo "✓ Готово:"
ls -lh "$SCRIPT_DIR"/saqta-logo-*.png 2>/dev/null

echo ""
echo "Дальше:"
echo "  1. cd tauri-app && npm run tauri icon ../assets/saqta-logo.png"
echo "     (генерит .icns, .ico, и все Tauri-размеры)"
echo "  2. Загрузи saqta-logo.png как Social Preview на"
echo "     https://github.com/moldabayevd/saqta/settings"
echo "  3. git add assets/ && git commit && git push"
