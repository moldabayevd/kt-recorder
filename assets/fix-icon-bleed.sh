#!/usr/bin/env bash
# fix-icon-bleed.sh — превращает иконку с собственным скруглением во
# full-bleed (edge-to-edge) для правильного macOS rounding.
#
# Проблема: PNG с уже нарисованной скруглённой рамкой → macOS поверх
# применяет squircle-маску → двойное скругление, пустые углы.
#
# Решение: заливаем углы тем же цветом фона (#F5F0E1 кремовый) до
# полного квадрата. macOS-маска отрежет лишнее.
#
# Использование:
#   bash assets/fix-icon-bleed.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT="$SCRIPT_DIR/saqta-logo.png"
OUTPUT="$SCRIPT_DIR/saqta-logo-bleed.png"

[ -f "$INPUT" ] || { echo "✗ Не найден: $INPUT" >&2; exit 1; }

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    echo "✗ ImageMagick не установлен:"
    echo "    brew install imagemagick"
    exit 1
fi

# Используем magick (ImageMagick 7) или convert (старая версия)
MAGICK="magick"
command -v magick >/dev/null 2>&1 || MAGICK="convert"

# Цвет фона кремовый — должен совпадать с фоном на иконке
BG="#F5F0E1"

echo "→ Заливаю углы цветом $BG..."

# 1. Делаем чистый квадрат 1024×1024 цвета BG
# 2. Накладываем оригинальную иконку поверх по центру
# Этот трюк убирает любую прозрачность по углам и заполняет до квадрата.
$MAGICK -size 1024x1024 "xc:$BG" \
        \( "$INPUT" -resize 1024x1024 \) \
        -gravity center -compose over -composite \
        "$OUTPUT"

echo "✓ Готово: $OUTPUT"
echo ""
echo "Теперь проверь визуально — углы должны быть кремовыми (не белые/прозрачные)."
echo ""
echo "Если ОК, замени оригинал:"
echo "    mv $OUTPUT $INPUT"
echo ""
echo "Затем перегенерь Tauri иконки:"
echo "    cd tauri-app && npm run tauri icon ../assets/saqta-logo.png"
