// API-обёртки над Tauri commands. Frontend зовёт эти функции, Rust-backend
// внутри запускает соответствующие bash-скрипты из ../scripts.

import { invoke } from "@tauri-apps/api/core";

export type RecordingStatus = "raw" | "transcribed" | "summarized";

export interface Recording {
  path: string;
  name: string;
  date: string;
  time: string;
  duration_secs: number | null;
  size_bytes: number;
  status: RecordingStatus;
  transcript_path: string | null;
  summary_path: string | null;
}

export interface Config {
  recordings_dir: string;
  whisper_model: string;
  whisper_lang: string;
  kk_backend: string;
  summarizer_backend: string;
  summarizer_model: string;
  summarizer_template: string;
}

/** Список всех записей в RECORDINGS_DIR со статусами. */
export async function listRecordings(): Promise<Recording[]> {
  return await invoke("list_recordings");
}

/** Запустить транскрипцию через scripts/transcribe-auto.sh */
export async function transcribe(filePath: string): Promise<string> {
  return await invoke("transcribe", { filePath });
}

/** Запустить саммари через scripts/summarize.sh */
export async function summarize(
  mdPath: string,
  template: string = "protocol",
): Promise<string> {
  return await invoke("summarize", { mdPath, template });
}

/** Запустить экспорт через scripts/export.sh */
export async function exportFile(
  mdPath: string,
  format: "pdf" | "docx" | "html",
): Promise<string> {
  return await invoke("export_file", { mdPath, format });
}

/** Открыть файл/папку в Finder */
export async function openInFinder(path: string): Promise<void> {
  return await invoke("open_in_finder", { path });
}

/** Прочитать конфиг */
export async function getConfig(): Promise<Config> {
  return await invoke("get_config");
}

/** Форматирование человекочитаемое */
export function formatDuration(seconds: number | null): string {
  if (!seconds) return "—";
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  return h > 0 ? `${h}ч ${m}м` : `${m}м`;
}

export function formatSize(bytes: number): string {
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(0)} KB`;
  if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(0)} MB`;
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} GB`;
}

export const STATUS_INFO: Record<RecordingStatus, { emoji: string; label: string; color: string }> = {
  raw: { emoji: "🔴", label: "не обработано", color: "#ef4444" },
  transcribed: { emoji: "🟡", label: "транскрипт", color: "#eab308" },
  summarized: { emoji: "🟢", label: "саммари готов", color: "#22c55e" },
};
