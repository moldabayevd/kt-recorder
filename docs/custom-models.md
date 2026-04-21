# Кастомные модели Whisper

По умолчанию KT Recorder использует `ggml-large-v3.bin` — универсальную модель от OpenAI. Для улучшения качества на конкретных языках, доменах или ускорения можно подключить другую.

## Официальные ggml-модели

Все совместимые с whisper.cpp модели лежат в [ggerganov/whisper.cpp](https://huggingface.co/ggerganov/whisper.cpp/tree/main) на HuggingFace.

| Модель | Размер | Когда использовать |
|--------|--------|-------------------|
| `ggml-large-v3.bin` | 3.1 ГБ | Универсальная, хороший русский (по умолчанию) |
| `ggml-large-v3-turbo.bin` | 1.6 ГБ | В 2-3× быстрее, качество чуть ниже |
| `ggml-medium.bin` | 1.5 ГБ | Компромисс для 8 ГБ RAM |
| `ggml-large-v3-q5_0.bin` | 1.1 ГБ | Квантованная, ~95% качества Large-v3 |
| `ggml-small.bin` | 488 МБ | Для быстрых черновых расшифровок |

Скачать любую:

```bash
cd ~/whisper-models
curl -L -O https://huggingface.co/ggerganov/whisper.cpp/resolve/main/MODEL_NAME.bin
```

Потом в `~/.config/kt-recorder/config.sh`:

```bash
WHISPER_MODEL="$HOME/whisper-models/MODEL_NAME.bin"
```

## Русский fine-tune (рекомендуется для рус. встреч)

[`antony66/whisper-large-v3-russian`](https://huggingface.co/antony66/whisper-large-v3-russian) — заточен под русский, WER ~6% на Common Voice против ~10% у базового Large-v3. Особенно хорош на разговорной речи и именах собственных.

GGML-версия для whisper.cpp:

```bash
cd ~/whisper-models
curl -L -o ggml-large-v3-russian.bin \
  https://huggingface.co/Limtech/whisper-large-v3-russian-ggml/resolve/main/ggml-model.bin
```

Обнови конфиг:

```bash
WHISPER_MODEL="$HOME/whisper-models/ggml-large-v3-russian.bin"
```

Перезапусти watcher:

```bash
launchctl kickstart -k gui/$(id -u)/com.ktrecorder.autotranscribe
```

## Другие языки

В `~/.config/kt-recorder/config.sh` меняешь `WHISPER_LANG`:

- `en` — английский
- `de` — немецкий
- `fr` — французский
- `es` — испанский
- `zh` — китайский
- `auto` — автодетект (не рекомендуется для смешанной речи, Whisper часто промахивается)

Полный список — [в документации Whisper](https://github.com/openai/whisper#available-models-and-languages).

## CoreML-ускорение (опционально)

На Apple Silicon whisper.cpp может использовать Apple Neural Engine через CoreML-обёртки моделей — это даёт прирост ~3× к Metal.

```bash
cd ~/whisper-models
curl -L -O https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-encoder.mlmodelc.zip
unzip ggml-large-v3-encoder.mlmodelc.zip
rm ggml-large-v3-encoder.mlmodelc.zip
```

CoreML-файл должен лежать рядом с ggml-бинарником и называться так же (с суффиксом `-encoder.mlmodelc`). whisper.cpp подхватит автоматически при первом запуске.

> ⚠️ При первом запуске с CoreML macOS будет компилировать модель под твой чип — это займёт 2-5 минут. Следующие запуски моментально.
