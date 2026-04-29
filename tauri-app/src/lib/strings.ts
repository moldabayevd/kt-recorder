// strings.ts — единое место для всех человекочитаемых текстов в UI.
// Любой технический термин из bash-скриптов превращается здесь
// в понятный обычному пользователю русский язык.

import type { RecordingStatus } from "./api";

/** Что показываем как «статус» в карточке записи. */
export const STATUS_LABELS: Record<
  RecordingStatus,
  { emoji: string; label: string; hint: string; color: string }
> = {
  raw: {
    emoji: "🆕",
    label: "Новая запись",
    hint: "Ещё не обработана. Нажмите «Получить текст» чтобы расшифровать.",
    color: "#3b82f6", // blue-500
  },
  transcribed: {
    emoji: "✅",
    label: "Текст готов",
    hint: "Расшифровка завершена. Можно сделать структурированные заметки.",
    color: "#eab308", // yellow-500
  },
  summarized: {
    emoji: "📝",
    label: "Заметки готовы",
    hint: "И текст, и заметки готовы. Можно скачать в PDF.",
    color: "#22c55e", // green-500
  },
};

/** Подписи для кнопок действий. */
export const ACTIONS = {
  transcribe: {
    label: "🎬 Получить текст",
    busy: "Расшифровываю встречу...",
    hint: "AI прослушает запись и превратит речь в текст. Занимает ~5–10% длительности встречи.",
  },
  retranscribe: {
    label: "🔄 Перезаписать текст",
    busy: "Заново расшифровываю...",
    hint: "Запустить расшифровку заново (если предыдущая была плохой).",
  },
  summarize: {
    label: "📝 Сделать заметки",
    busy: "Готовлю структурированные заметки...",
    hint: "Превратит текст в протокол: участники, темы, цитаты, задачи.",
  },
  resummarize: {
    label: "🔄 Обновить заметки",
    busy: "Перегенерирую заметки...",
    hint: "Перезапустить — например, после смены шаблона.",
  },
  exportPdf: {
    label: "📄 Скачать как PDF",
    busy: "Готовлю PDF...",
    hint: "Сохранит заметки в красивый PDF — можно отправить боссу.",
  },
  exportDocx: {
    label: "📝 Скачать как Word",
    busy: "Готовлю Word-документ...",
    hint: "Сохранит в DOCX — можно дальше редактировать.",
  },
  openFolder: {
    label: "📂 Показать в Finder",
    hint: "Откроет папку с этой встречей.",
  },
  viewTranscript: {
    label: "👀 Посмотреть текст",
    hint: "Откроет полный текст встречи.",
  },
  viewSummary: {
    label: "👀 Посмотреть заметки",
    hint: "Откроет структурированные заметки (протокол).",
  },
} as const;

/** Дружелюбные тексты в шапке. */
export const HEADER = {
  title: "Saqta",
  subtitle: "Ваши встречи — в текст и заметки",
};

/** Тексты для пустого состояния (нет записей вообще). */
export const EMPTY_STATE = {
  title: "Здесь будут ваши встречи",
  steps: [
    {
      icon: "🎙️",
      title: "Начните запись",
      description:
        "Нажмите ⌘⇧R в любой момент — даже когда уже идёт Zoom/Teams встреча. Saqta запишет звук и собеседника.",
    },
    {
      icon: "⏹️",
      title: "Остановите запись",
      description:
        "Снова ⌘⇧R когда встреча закончится. Файл автоматически появится в этом окне.",
    },
    {
      icon: "✨",
      title: "Получите текст и заметки",
      description:
        "Нажмите «Получить текст» — AI прослушает и расшифрует. Потом «Сделать заметки» — получите готовый протокол.",
    },
  ],
  privacyNote:
    "Всё происходит на вашем Mac. Ни один байт не уходит в облако.",
};

/** Сообщения о прогрессе (для спиннера). */
export const PROGRESS_MESSAGES = {
  detectLang: "Определяю язык записи...",
  extractAudio: "Готовлю аудио...",
  transcribing: "AI слушает встречу...",
  summarizing: "Структурирую заметки...",
  exporting: "Создаю документ...",
};

/** Сообщения об ошибках в человекочитаемом виде. */
export function friendlyError(raw: string): string {
  const r = raw.toLowerCase();
  if (r.includes("whisper-cli") && r.includes("not found")) {
    return "Не установлен whisper-cli. Откройте Терминал и выполните:\n  brew install whisper-cpp";
  }
  if (r.includes("ffmpeg") && r.includes("not found")) {
    return "Не установлен ffmpeg:\n  brew install ffmpeg";
  }
  if (r.includes("ollama")) {
    return "Ollama не запущена или не установлена:\n  brew install ollama && brew services start ollama";
  }
  if (r.includes("permission denied")) {
    return "Нет доступа к файлу. Возможно, нужно дать macOS права на чтение папки в Settings → Privacy.";
  }
  if (r.includes("no such file")) {
    return "Файл не найден. Возможно, его уже переместили или удалили.";
  }
  // Если ничего не подошло — покажем оригинал, но с префиксом
  return `Что-то пошло не так:\n${raw}`;
}

/** Форматирование длительности в человеческий вид. */
export function formatDurationFriendly(seconds: number | null): string {
  if (!seconds) return "—";
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (h > 0) return `${h} ч ${m} мин`;
  if (m > 0) return `${m} мин`;
  return `<1 мин`;
}

/** Форматирование даты «вчера / сегодня / 3 дня назад». */
export function formatDateFriendly(dateStr: string): string {
  if (!dateStr || dateStr === "—") return "";
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return dateStr;

  const today = new Date();
  const diff = Math.floor((today.getTime() - d.getTime()) / (1000 * 60 * 60 * 24));

  if (diff === 0) return "Сегодня";
  if (diff === 1) return "Вчера";
  if (diff < 7) return `${diff} дн. назад`;
  if (diff < 30) return `${Math.floor(diff / 7)} нед. назад`;

  return d.toLocaleDateString("ru-RU", {
    day: "numeric",
    month: "long",
    year: today.getFullYear() === d.getFullYear() ? undefined : "numeric",
  });
}
