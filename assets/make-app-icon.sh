#!/usr/bin/env bash
# make-app-icon.sh — превращает прозрачный saqta-logo.png в edge-to-edge
# квадратную иконку для macOS Dock / DMG.
#
# Логика: берём прозрачный микрофон → сажаем на кремовый Samruk-фон с
# тонкой золотой рамкой → результат подходит для Tauri/macOS app icon.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT="$SCRIPT_DIR/saqta-logo.png"
OUTPUT="$SCRIPT_DIR/saqta-app-icon.png"

[ -f "$INPUT" ] || { echo "✗ Не найден: $INPUT" >&2; exit 1; }

if ! command -v magick >/dev/null 2>&1; then
    echo "✗ Нужен ImageMagick: brew install imagemagick" >&2
    exit 1
fi

echo "→ Делаю edge-to-edge app icon с кремовым Samruk-фоном..."

# Кремовый радиальный градиент для глубины (как у Samruk-Kazyna)
magick -size 1024x1024 \
    radial-gradient:'#FAF6E8'-'#E8DEC4' \
    \( "$INPUT" -resize 600x600 \) \
    -gravity center -compose over -composite \
    "$OUTPUT"

size=$(du -h "$OUTPUT" | awk '{print $1}')
echo "✓ Готово: $OUTPUT ($size)"
echo ""
echo "Использование для Tauri:"
echo "  cd tauri-app && npm run tauri icon ../assets/saqta-app-icon.png"
echo ""
echo "(macOS применит свою скруглённую маску при отображении в Dock.)"
