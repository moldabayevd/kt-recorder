#!/usr/bin/env bash
# KT Recorder with STT - installer
# https://github.com/YOUR_USERNAME/kt-recorder-with-stt

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Banner -----------------------------------------------------------------

echo -e "${BLUE}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║                                           ║
║     KT Recorder with STT — installer      ║
║     Privacy-first meeting transcriber     ║
║                                           ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"

info()    { echo -e "${BLUE}→${NC} $*"; }
ok()      { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
err()     { echo -e "${RED}✗${NC} $*" >&2; }

# --- System checks ----------------------------------------------------------

OS=$(uname -s)
if [ "$OS" != "Darwin" ]; then
    err "Только macOS. У вас: $OS"
    exit 1
fi

MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
if [ "$MACOS_VERSION" -lt 13 ]; then
    err "Нужен macOS 13+. У вас: $(sw_vers -productVersion)"
    exit 1
fi
ok "macOS $(sw_vers -productVersion)"

ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    ok "Apple Silicon ($ARCH) — Metal-ускорение будет активно"
else
    warn "Intel Mac — Metal недоступен, транскрибация медленнее"
fi

echo ""

# --- Homebrew ---------------------------------------------------------------

if ! command -v brew &> /dev/null; then
    warn "Homebrew не найден. Устанавливаю..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    ok "Homebrew: $(brew --version | head -1)"
fi

# --- Dependencies -----------------------------------------------------------

echo ""
info "Устанавливаю CLI-зависимости..."

BREW_DEPS=(whisper-cpp ffmpeg fswatch terminal-notifier jq)
for dep in "${BREW_DEPS[@]}"; do
    if brew list --formula "$dep" &> /dev/null; then
        ok "$dep уже установлен"
    else
        info "Ставлю $dep..."
        brew install "$dep"
    fi
done

echo ""
info "Устанавливаю QuickRecorder..."
if brew list --cask quickrecorder &> /dev/null; then
    ok "QuickRecorder уже установлен"
else
    brew install --cask quickrecorder
fi

# --- Whisper model ----------------------------------------------------------

MODELS_DIR="$HOME/whisper-models"
MODEL_FILE="$MODELS_DIR/ggml-large-v3.bin"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin"

mkdir -p "$MODELS_DIR"

if [ -f "$MODEL_FILE" ]; then
    SIZE=$(du -h "$MODEL_FILE" | cut -f1)
    ok "Модель Large-v3 уже скачана ($SIZE)"
else
    echo ""
    info "Качаю Whisper Large-v3 (~3 ГБ, может занять несколько минут)..."
    curl -L --progress-bar -o "$MODEL_FILE" "$MODEL_URL"
    ok "Модель скачана"
fi

# --- Install scripts --------------------------------------------------------

INSTALL_DIR="$HOME/bin/kt-recorder"
mkdir -p "$INSTALL_DIR"

echo ""
info "Устанавливаю скрипты в $INSTALL_DIR"
cp "$SCRIPT_DIR"/scripts/*.sh "$INSTALL_DIR/"
cp -r "$SCRIPT_DIR"/launchagents "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR"/*.sh "$INSTALL_DIR"/launchagents/*.sh
ok "Скрипты установлены"

# --- Config -----------------------------------------------------------------

CONFIG_DIR="$HOME/.config/kt-recorder"
CONFIG_FILE="$CONFIG_DIR/config.sh"

mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
# KT Recorder configuration
# Полная документация: https://github.com/YOUR_USERNAME/kt-recorder-with-stt

# Папка, за которой следит watcher
RECORDINGS_DIR="\$HOME/Recordings"

# Путь к модели Whisper (см. docs/custom-models.md для альтернатив)
WHISPER_MODEL="$MODEL_FILE"

# Язык транскрибации: ru, en, de, fr, es, auto, ...
WHISPER_LANG="ru"

# Форматы экспорта через запятую: txt, vtt, srt, json
OUTPUT_FORMATS="txt,vtt"

# Открывать Finder с папкой встречи после готовности
OPEN_FINDER_ON_DONE=true

# Звук уведомления о готовности (Basso, Glass, Ping, Purr, Sosumi, Submarine)
NOTIFY_SOUND="Glass"
EOF
    ok "Создан конфиг: $CONFIG_FILE"
else
    ok "Конфиг уже существует: $CONFIG_FILE"
fi

mkdir -p "$HOME/Recordings"

# --- LaunchAgent ------------------------------------------------------------

echo ""
echo -n "Настроить автозапуск watcher при входе в систему? [Y/n] "
read -r REPLY
REPLY=${REPLY:-Y}
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$INSTALL_DIR/launchagents/install-launchagent.sh"
else
    info "Пропущено. Запускать watcher вручную: $INSTALL_DIR/auto-transcribe.sh"
fi

# --- Final message ----------------------------------------------------------

echo ""
echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║            Установка завершена! 🎉         ║${NC}"
echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Следующие шаги:${NC}"
echo ""
echo "  1. Открой QuickRecorder.app и настрой:"
echo "     • Save to: ~/Recordings"
echo "     • Hotkey: ⌘⇧R"
echo "     • Separate audio tracks: on"
echo "     • Format: MP4"
echo ""
echo "  2. Дай разрешения в System Settings → Privacy & Security:"
echo "     • Screen Recording → QuickRecorder"
echo "     • Microphone → QuickRecorder"
echo ""
echo "  3. Нажми ⌘⇧R — и погнали!"
echo ""
echo -e "${BLUE}Документация:${NC} https://github.com/YOUR_USERNAME/kt-recorder-with-stt"
echo -e "${BLUE}Issues:${NC}        https://github.com/YOUR_USERNAME/kt-recorder-with-stt/issues"
echo ""
