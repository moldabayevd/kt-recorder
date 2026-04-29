# 🎨 Saqta Assets

Все визуальные материалы проекта.

## Структура

```
assets/
├── saqta-logo.png         ← ОСНОВНОЙ ЛОГОТИП (1024×1024 PNG)
├── saqta-logo-512.png     ← для README, GitHub social preview
├── saqta-logo-128.png     ← для favicon, маленьких контекстов
├── saqta-logo-32.png      ← для CI badges, очень мелких мест
├── demo.gif               ← демо-флоу (записываем после первой сборки)
└── README.md              ← этот файл
```

## Как залить логотип

### 1. Положи оригинал

Положи свою сгенерированную PNG (1024×1024, тот вариант с микрофоном
и завитком снизу в Samruk-палитре) в:

```
assets/saqta-logo.png
```

### 2. Сгенерь все размеры одной командой

```bash
bash assets/generate-sizes.sh
```

Скрипт создаст 512/128/32 PNG из оригинала через `sips` (входит в macOS).

### 3. Сгенерь Tauri иконки

```bash
cd tauri-app
npm run tauri icon ../assets/saqta-logo.png
```

Это создаст автоматически:
- `tauri-app/src-tauri/icons/32x32.png`
- `tauri-app/src-tauri/icons/128x128.png`
- `tauri-app/src-tauri/icons/128x128@2x.png`
- `tauri-app/src-tauri/icons/icon.icns` (macOS)
- `tauri-app/src-tauri/icons/icon.ico` (Windows)

### 4. GitHub Social Preview

Открой https://github.com/moldabayevd/saqta/settings →
**Options** → **Social preview** → **Edit** → загрузи `saqta-logo.png`.

Это **картинка которая показывается** когда кто-то расшарит ссылку
на репо в LinkedIn / Twitter / Telegram. Очень важно для маркетинга.

Рекомендуемый размер для social preview: **1280×640px** (соотношение 2:1).
Если хочешь — можно сделать отдельную карточку:

```bash
# на маке через ImageMagick
brew install imagemagick

magick assets/saqta-logo.png \
       -resize 600x600 \
       -gravity center \
       -background "#F5F0E1" \
       -extent 1280x640 \
       assets/saqta-social-preview.png
```

Или вручную в Figma / Photoshop.

### 5. README

Логотип уже подключен в `README.md` через:

```markdown
<img src="assets/saqta-logo-512.png" width="200" />
```

Просто обнови файл — README автоматически подхватит.

## Цветовая палитра (для справки)

Из логотипа Samruk-Kazyna:

| Цвет | Hex | Где использовать |
|---|---|---|
| Тёмно-синий | `#1F3A5F` | основной контур, акценты |
| Глубокий синий | `#142847` | тени, dark mode |
| Бронзовое золото | `#A98B5C` | рамки, лучи, орнамент |
| Тёмное золото | `#8B7355` | depth, hover |
| Светлое золото | `#C9A961` | блики |
| Кремовый | `#F5F0E1` | основной фон |
| Чистый белый | `#FFFFFF` | альтернативный фон |
