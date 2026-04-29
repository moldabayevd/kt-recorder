#!/usr/bin/env bash
# compose-on-glass.sh — накладывает прозрачный микрофон на Liquid Glass подложку.
#
# Вход:
#   assets/saqta-mic.png        — прозрачный микрофон (двухтонный navy+gold)
#   assets/glass-tile.png       — сгенерённая Nano Banano пустая стеклянная плитка
#                                  ИЛИ построим простую через ImageMagick
#
# Выход:
#   assets/saqta-logo.png       — готовая композиция 1024x1024
#
# Использование:
#   bash assets/compose-on-glass.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIC="$SCRIPT_DIR/saqta-mic.png"
GLASS="$SCRIPT_DIR/glass-tile.png"
OUTPUT="$SCRIPT_DIR/saqta-logo.png"

[ -f "$MIC" ] || { echo "✗ Не найден: $MIC" >&2; exit 1; }

if ! command -v magick >/dev/null 2>&1; then
    echo "✗ Нужен ImageMagick: brew install imagemagick" >&2
    exit 1
fi

# Если нет готовой стеклянной плитки — генерим простую программно
if [ ! -f "$GLASS" ]; then
    echo "→ Генерю простую glass-плитку (нет готовой)..."

    # 1024x1024 cream-glass tile с радиальным градиентом и rim
    magick -size 1024x1024 \
        \( -size 1024x1024 radial-gradient:"#FFFEF5"-"#E8DEC4" \) \
        \( -size 1024x1024 xc:none \
           -fill "#FFFFFF80" \
           -draw "roundrectangle 60,60 200,964 24,24" \
           -blur 0x40 \) \
        -compose multiply -composite \
        \( -size 1024x1024 xc:none \
           -fill none -stroke "#A98B5C" -strokewidth 4 \
           -draw "roundrectangle 30,30 994,994 120,120" \
           -blur 0x2 \) \
        -compose screen -composite \
        \( -size 1024x1024 xc:black \
           -fill white \
           -draw "roundrectangle 0,0 1024,1024 180,180" \) \
        -alpha set -compose CopyOpacity -composite \
        "$GLASS"
    echo "  Базовая стеклянная плитка: $GLASS"
fi

echo "→ Накладываю микрофон на стекло..."

# Ресайз микрофона до ~55% canvas height и центрируем
magick "$GLASS" \
    \( "$MIC" -resize x560 \) \
    -gravity center -compose over -composite \
    "$OUTPUT"

size=$(du -h "$OUTPUT" | awk '{print $1}')
echo "✓ Готово: $OUTPUT ($size)"
echo ""
echo "Дальше:"
echo "  bash assets/generate-sizes.sh                              # все размеры"
echo "  cd tauri-app && npm run tauri icon ../assets/saqta-logo.png # Tauri"
