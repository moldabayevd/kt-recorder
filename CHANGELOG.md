# Changelog

Все значимые изменения проекта документируются в этом файле.

Формат основан на [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/),
проект следует [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Диаризация спикеров (v0.2)
- Локальная саммаризация через Ollama (v0.3)
- Swift menu bar app (v0.4)

## [0.1.0] - 2026-04-22

### Added
- Автоматическая транскрибация через watcher на `fswatch`
- One-command установка через `install.sh`
- LaunchAgent для автозапуска при логине
- Поддержка Whisper Large-v3 с Metal-ускорением
- Экспорт в Markdown с YAML frontmatter (Obsidian-совместимо)
- Генерация VTT-субтитров с таймкодами
- Нативные уведомления macOS на каждом этапе
- Ручная транскрибация через `transcribe-file.sh`
- Конфигурационный файл `~/.config/kt-recorder/config.sh`
- Документация: `custom-models.md`, `troubleshooting.md`
- CI через GitHub Actions: shellcheck для всех скриптов

### Security
- Полная офлайн-работа после первичной загрузки модели
- Никаких внешних API-вызовов в runtime

[Unreleased]: https://github.com/YOUR_USERNAME/kt-recorder-with-stt/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/YOUR_USERNAME/kt-recorder-with-stt/releases/tag/v0.1.0
