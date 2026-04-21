#!/usr/bin/env bash
# auto-transcribe.sh — watcher, который следит за папкой записей
# и автоматически транскрибирует новые файлы через whisper.cpp

set -euo pipefail

# --- Load config ------------------------------------------------------------

CONFIG_FILE="$HOME/.config/kt-recorder/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "✗ Config not found: $CONFIG_FILE" >&2
    echo "  Запусти ./install.sh из репы" >&2
    exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG_FILE"

# Defaults
: "${RECORDINGS_DIR:=$HOME/Recordings}"
: "${WHISPER_MODEL:=$HOME/whisper-models/ggml-large-v3.bin}"
: "${WHISPER_LANG:=ru}"
: "${OUTPUT_FORMATS:=txt,vtt}"
: "${OPEN_FINDER_ON_DONE:=true}"
: "${NOTIFY_SOUND:=Glass}"

# --- Dependencies check -----------------------------------------------------

for cmd in fswatch ffmpeg whisper-cli terminal-notifier; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "✗ Не найдено: $cmd — запусти install.sh" >&2
        exit 1
    fi
done

if [ ! -f "$WHISPER_MODEL" ]; then
    echo "✗ Модель не найдена: $WHISPER_MODEL" >&2
    exit 1
fi

mkdir -p "$RECORDINGS_DIR"

# --- Notifications ----------------------------------------------------------

notify() {
    local title="$1"
    local message="$2"
    local sound="${3:-default}"
    terminal-notifier -title "$title" -message "$message" \
        -sound "$sound" 2>/dev/null || true
}

notify_done() {
    local title="$1"
    local message="$2"
    local path="$3"
    if [ "$OPEN_FINDER_ON_DONE" = "true" ]; then
        terminal-notifier -title "$title" -message "$message" \
            -sound "$NOTIFY_SOUND" -execute "open '$path'" 2>/dev/null || true
    else
        terminal-notifier -title "$title" -message "$message" \
            -sound "$NOTIFY_SOUND" 2>/dev/null || true
    fi
}

# --- Processing -------------------------------------------------------------

process_file() {
    local file="$1"
    local basename
    basename=$(basename "$file")
    local name="${basename%.*}"
    local dir
    dir=$(dirname "$file")

    echo "[$(date '+%H:%M:%S')] Processing: $basename"
    notify "KT Recorder" "Начинаю транскрибацию: $basename"

    # Create subfolder for this meeting
    local meeting_dir="$dir/$name"
    mkdir -p "$meeting_dir"
    mv "$file" "$meeting_dir/$basename"

    # Extract audio as 16kHz mono WAV for whisper
    local audio_wav="$meeting_dir/_audio.wav"
    if ! ffmpeg -y -i "$meeting_dir/$basename" \
                -ar 16000 -ac 1 -c:a pcm_s16le \
                "$audio_wav" 2>/dev/null; then
        notify "KT Recorder ✗" "Не удалось извлечь аудио: $basename" "Basso"
        return 1
    fi

    # Build format flags
    local format_flags=()
    IFS=',' read -ra FORMATS <<< "$OUTPUT_FORMATS"
    for fmt in "${FORMATS[@]}"; do
        case "$fmt" in
            txt)  format_flags+=(--output-txt) ;;
            vtt)  format_flags+=(--output-vtt) ;;
            srt)  format_flags+=(--output-srt) ;;
            json) format_flags+=(--output-json) ;;
        esac
    done

    # Run whisper.cpp (Metal auto-enabled on Apple Silicon)
    if ! whisper-cli -m "$WHISPER_MODEL" -l "$WHISPER_LANG" \
                     -f "$audio_wav" \
                     "${format_flags[@]}" \
                     -of "$meeting_dir/_transcript" \
                     2>&1 | tail -3; then
        notify "KT Recorder ✗" "Ошибка whisper: $basename" "Basso"
        rm -f "$audio_wav"
        return 1
    fi

    # Cleanup intermediate WAV
    rm -f "$audio_wav"

    # Generate beautiful Markdown with frontmatter
    local md_file="$meeting_dir/$name.md"
    local date_str
    date_str=$(date '+%Y-%m-%d %H:%M')
    local date_iso
    date_iso=$(date '+%Y-%m-%d')

    {
        echo "---"
        echo "title: \"$name\""
        echo "date: $date_iso"
        echo "source: kt-recorder"
        echo "language: $WHISPER_LANG"
        echo "tags:"
        echo "  - meeting"
        echo "  - transcript"
        echo "---"
        echo ""
        echo "# $name"
        echo ""
        echo "**Дата:** $date_str  "
        echo "**Видео:** [\`$basename\`]($basename)  "
        if [ -f "$meeting_dir/_transcript.vtt" ]; then
            echo "**Субтитры:** [\`_transcript.vtt\`](_transcript.vtt)"
        fi
        echo ""
        echo "---"
        echo ""
        echo "## Транскрипт"
        echo ""
        if [ -f "$meeting_dir/_transcript.txt" ]; then
            cat "$meeting_dir/_transcript.txt"
        else
            echo "_Транскрипт не сгенерирован_"
        fi
    } > "$md_file"

    # Remove intermediate txt, keep vtt for video players
    rm -f "$meeting_dir/_transcript.txt"

    echo "[$(date '+%H:%M:%S')] ✓ Done: $meeting_dir"
    notify_done "KT Recorder ✓" "Готово: $name" "$meeting_dir"
}

# --- Main loop --------------------------------------------------------------

echo "╔════════════════════════════════════════╗"
echo "║  KT Recorder — watcher запущен         ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Слежу за:  $RECORDINGS_DIR"
echo "Модель:    $WHISPER_MODEL"
echo "Язык:      $WHISPER_LANG"
echo "Форматы:   $OUTPUT_FORMATS"
echo ""

notify "KT Recorder" "Watcher запущен — слежу за $RECORDINGS_DIR"

# fswatch with null separator for filenames with spaces
fswatch -0 --event Created --event Renamed "$RECORDINGS_DIR" | \
while read -r -d "" file; do
    # Ignore events inside subfolders (processed meetings)
    if [[ "$(dirname "$file")" != "$RECORDINGS_DIR" ]]; then
        continue
    fi

    # Only audio/video files
    if [[ "$file" =~ \.(mp4|mov|m4a|wav|mp3)$ ]]; then
        # Let the file finish writing to disk
        sleep 3
        if [ -f "$file" ]; then
            process_file "$file" || echo "✗ Failed: $file"
        fi
    fi
done
