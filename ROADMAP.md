# 🗺️ KT Recorder Roadmap

Дорожная карта проекта. Главная цель — забрать все хорошие фичи у конкурентов
(особенно [Meetily](https://github.com/Zackriya-Solutions/meetily)),
оставаясь **бесплатным opensource-проектом** с упором на казахский язык
и реалии Казахстана.

> **Принцип:** не платим за фичи которые конкуренты прячут в PRO. Всё, что
> Meetily берёт деньги (diarization, PDF/DOCX, custom templates,
> auto-detect) — у нас должно быть **бесплатно из коробки**.

---

## v0.1.0 — текущая (released)

См. [CHANGELOG.md](CHANGELOG.md) — базовый рабочий пайплайн.

- Запись через QuickRecorder (⌘⇧R)
- Транскрипция через whisper.cpp + Silero VAD
- Whisper-large-v3-russian fine-tune (antony66) для русского
- Initial prompt словарь имён/терминов
- Markdown + VTT экспорт, Obsidian-совместимо
- Bash + gum TUI меню
- Ярлычок на десктоп для on-demand запуска
- Поддержка казахского + kk/ru code-switching через router (Qwen3-ASR)
- Опциональная саммаризация через Ollama / Claude API

---

## v0.2.0 — «Native UI» (1-2 недели)

Цель: убрать терминал из user flow для основных действий, не теряя
хакабельность bash-скриптов под капотом.

### Tauri-приложение
- [ ] Обёртка вокруг существующих bash-скриптов (Tauri 2.x, Svelte/Solid фронт)
- [ ] Окно со списком записей (тот же контент что в `kt` меню сейчас)
- [ ] Кнопки: Транскрибировать / Перетранскрибировать / Открыть папку
- [ ] Иконка в Dock + индикатор статуса в menu bar
- [ ] Drag-and-drop файла встречи прямо на иконку

### Auto-detect meetings
- [ ] AppleScript-watcher следит за процессами `zoom.us`,
      `Microsoft Teams`, активным URL Chrome (`meet.google.com`)
- [ ] При начале встречи показывает уведомление: «Записать встречу?»
- [ ] Опция настройки в config.sh: `AUTO_DETECT_MEETINGS=true`

### Polish
- [ ] DMG-installer вместо `git clone + install.sh`
- [ ] Настройки доступны через UI (без правки config.sh руками)
- [ ] Иконка приложения (попросить дизайнера или сгенерить)

---

## v0.3.0 — «Pro-фичи бесплатно» (1-2 недели)

Цель: догнать и перегнать платный Meetily PRO.

### Speaker diarization (без 2 дорожек)
- [ ] Интеграция [pyannote.audio v3.1+](https://github.com/pyannote/pyannote-audio)
- [ ] `scripts/diarize.sh` — на вход одна mp3, на выход разметка по спикерам
- [ ] Объединение с whisper-транскриптом → `**Спикер 1:** ... **Спикер 2:** ...`
- [ ] Опционально: автоматическое присвоение имён через LLM
      («первый спикер представился как Марат → подставить»)

### Экспорт в PDF / DOCX
- [ ] `scripts/export.sh meeting.md --format pdf|docx`
- [ ] pandoc + кастомный LaTeX/Word шаблон с логотипом проекта
- [ ] Шаблоны: «протокол совещания», «1:1 заметки», «интервью»

### Custom summary templates
- [ ] `~/.config/kt-recorder/templates/<name>.txt` с разными промптами
- [ ] В `kt` меню: «Сделать саммари → выбрать шаблон»
- [ ] Встроенные: `protocol`, `1on1`, `interview`, `lecture`, `kazakh-formal`

### Гибкие LLM провайдеры
- [ ] `SUMMARIZER_BACKEND="groq"` — бесплатный Llama 3.3 70B через Groq API
- [ ] `SUMMARIZER_BACKEND="openrouter"` — любая модель из OpenRouter
- [ ] `SUMMARIZER_BACKEND="vllm"` — кастомный OpenAI-compatible endpoint
      (для корпоративных GPU-кластеров типа H200 в Казахтелекоме)
- [ ] `SUMMARIZER_BACKEND="lmstudio"` — локальный LM Studio сервер

---

## v0.4.0 — «Live» (1-2 недели)

Цель: видеть транскрипт во время встречи, делать пометки на лету.

### Streaming transcription
- [ ] Использование `whisper-stream` из whisper.cpp
- [ ] 5-10 секундные чанки с overlap для непрерывности
- [ ] Только для **ru/en** — на казахском короткие чанки дают плохое качество
- [ ] Полная транскрипция всё равно после записи через основной пайплайн
      (для итогового качества)

### Live UI
- [ ] Окно с прокручивающимся транскриптом во время записи
- [ ] Возможность кликнуть на фразу → ставится таймстамп-маркер
- [ ] Заметки на ходу: `Ctrl+N` → быстрая заметка с таймкодом

### Hotkeys во время встречи
- [ ] `Ctrl+Shift+M` — пометить «важный момент» (для последующего саммари)
- [ ] `Ctrl+Shift+T` — пометить «задача / action item»
- [ ] `Ctrl+Shift+Q` — пометить «вопрос для уточнения»

---

## v0.5.0 — «Public release» (2-3 недели)

Цель: проект готов к использованию посторонними людьми. Публикация на
HackerNews, Product Hunt, r/macapps.

### Cross-platform
- [ ] **Windows-версия**: PortAudio для записи, ffmpeg для обработки.
      QuickRecorder заменить на встроенный recorder в Tauri-app.
- [ ] **Linux-версия**: PulseAudio/PipeWire запись, остальное идентично

### Локализация интерфейса
- [ ] Русский (default)
- [ ] Казахский
- [ ] English

### Distribution
- [ ] Homebrew tap: `brew install moldabayevd/tap/kt-recorder`
- [ ] Подписанный DMG (нужен Apple Developer account, $99/год)
- [ ] MSI-installer для Windows
- [ ] AppImage / .deb / .rpm для Linux
- [ ] Auto-update через Tauri updater

### Документация
- [ ] Видео-демо (запись→транскрипция→саммари за 3 минуты)
- [ ] Сравнительная таблица vs Otter.ai, Fireflies, Krisp, Meetily
- [ ] Публичный пример протокола встречи
- [ ] Гайд «как настроить под свой корпоративный словарь»

---

## v0.6.0 — «Personal LoRA» (после накопления данных)

Цель: персональный fine-tune под голоса коллег, термины компании,
твою акустику.

### Data collection pipeline
- [ ] `scripts/export-training-data.sh` — собирает все исправленные
      пользователем `.md` + `.vtt` пары
- [ ] Авто-нарезка на 15-секундные сегменты
- [ ] Экспорт в HuggingFace `datasets` формат

### LoRA training
- [ ] `training/finetune-lora.py` — на 4070 12GB или M-серии 24GB+
- [ ] Базовые модели: whisper-large-v3-turbo, Qwen3-ASR-1.7B
- [ ] Конвертация результата в ggml для использования в whisper.cpp

### Continuous learning
- [ ] Каждые N встреч авто-предложение «обновить персональную модель»
- [ ] A/B сравнение: новая LoRA vs старая на отложенной выборке
- [ ] Откат если новая хуже

---

## v0.7.0+ — «Будущее»

Гипотезы, неприоритизировано:

- **Qwen3.5-Omni Light GGUF** — когда выйдут open-кванты, заменим
  весь STT+LLM пайплайн на одну модель (audio→summary за один проход)
- **Real-time перевод** — kk↔ru↔en во время встречи (для смешанных команд)
- **Vector DB всех транскриптов** — поиск по истории встреч (Qdrant/LanceDB
  локально)
- **Telegram-бот** — отправил голосовуху → получил текстовый протокол
- **Mobile companion** — iOS/Android приложение для записи через телефон,
  обработка на маке (синк через iCloud / Syncthing)
- **MCP server** — kt-recorder как MCP-source для Claude Desktop / Zed,
  чтобы AI мог напрямую читать твои встречи
- **Slack / Telegram интеграция** — автопостинг саммари в канал
- **Calendar integration** — создаёт `.md` заранее с участниками из
  Google/Apple Calendar

---

## Что НЕ делаем

- ❌ **Облачная версия / SaaS** — концепция проекта = «всё локально»
- ❌ **PRO-модель** — оставляем 100% open source без paywalled фич
- ❌ **Свой видео-конференс** — мы дополнение к Zoom/Meet/Teams,
  не их замена
- ❌ **Браузерное расширение** — лишний attack surface, всё через
  системные API
- ❌ **Фокус на английский рынок** — кор-аудитория = русско/казахскоязычные
  команды (хотя i18n будет, главный приоритет ясен)

---

## Чем мы лучше Meetily после v0.5

| Фича | Meetily Free | Meetily PRO ($) | KT Recorder v0.5 |
|---|---|---|---|
| Native UI | ✅ | ✅ | ✅ |
| Live transcription | ✅ | ✅ | ✅ |
| Auto-detect meetings | ❌ | ✅ | ✅ **бесплатно** |
| Speaker diarization | ❌ | ✅ | ✅ **бесплатно** |
| PDF/DOCX export | ❌ | ✅ | ✅ **бесплатно** |
| Custom templates | ❌ | ✅ | ✅ **бесплатно** |
| Казахский язык | ❌ | ❌ | ✅ |
| kk+ru code-switching | ❌ | ❌ | ✅ |
| Whisper-russian fine-tune | ❌ | ❌ | ✅ |
| Initial prompt vocab | ❌ | ❌ | ✅ |
| Personal LoRA training | ❌ | ❌ | ✅ (v0.6) |
| Корпоративный vLLM endpoint | ❌ | ❌ | ✅ |
| 2-track diarization | ❌ | ❌ | ✅ |
| Cross-platform | ✅ | ✅ | ✅ (v0.5) |
| Цена | 0 | $$$ | **0** |

---

## Контрибьюторам

Хочешь помочь? Начни с любой [ ] из v0.2 — это самый ближний релиз.
Pull-request'ы welcome, см. [CONTRIBUTING.md](CONTRIBUTING.md).

Большие архитектурные изменения — лучше сначала открыть Issue с RFC,
обсудим подход.
