<script lang="ts">
  import {
    type Recording,
    STATUS_INFO,
    formatDuration,
    formatSize,
    transcribe,
    summarize,
    exportFile,
    openInFinder,
  } from "./api";

  export let rec: Recording;
  export let onUpdate: () => void;

  let busy = false;
  let busyMessage = "";

  async function run<T>(message: string, fn: () => Promise<T>) {
    busy = true;
    busyMessage = message;
    try {
      await fn();
      onUpdate();
    } catch (e) {
      alert(`Ошибка: ${e}`);
    } finally {
      busy = false;
      busyMessage = "";
    }
  }

  $: status = STATUS_INFO[rec.status];
</script>

<div class="recording" class:busy>
  <div class="header">
    <span class="status" style="color: {status.color}">{status.emoji}</span>
    <div class="meta">
      <div class="title">{rec.name}</div>
      <div class="info">
        {rec.date} {rec.time} · {formatDuration(rec.duration_secs)} ·
        {formatSize(rec.size_bytes)} · {status.label}
      </div>
    </div>
  </div>

  {#if busy}
    <div class="busy-bar">
      <div class="spinner" />
      <span>{busyMessage}</span>
    </div>
  {:else}
    <div class="actions">
      {#if rec.status === "raw"}
        <button on:click={() => run("Транскрибирую…", () => transcribe(rec.path))}>
          🎬 Транскрибировать
        </button>
      {:else if rec.status === "transcribed" && rec.transcript_path}
        <button
          on:click={() =>
            run("Саммари…", () => summarize(rec.transcript_path!, "protocol"))}
        >
          📝 Саммари
        </button>
        <button on:click={() => openInFinder(rec.transcript_path!)}>👀 Транскрипт</button>
      {:else if rec.status === "summarized" && rec.summary_path}
        <button
          on:click={() => run("PDF…", () => exportFile(rec.summary_path!, "pdf"))}
        >
          📄 PDF
        </button>
        <button on:click={() => openInFinder(rec.summary_path!)}>👀 Саммари</button>
      {/if}
      <button class="secondary" on:click={() => openInFinder(rec.path)}>📂 Папка</button>
    </div>
  {/if}
</div>

<style>
  .recording {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 16px 20px;
    margin-bottom: 12px;
    transition: border-color 0.15s;
  }
  .recording:hover {
    border-color: var(--accent);
  }
  .recording.busy {
    opacity: 0.7;
  }
  .header {
    display: flex;
    gap: 12px;
    align-items: flex-start;
    margin-bottom: 12px;
  }
  .status {
    font-size: 20px;
    line-height: 1;
    margin-top: 2px;
  }
  .meta {
    flex: 1;
  }
  .title {
    font-weight: 600;
    font-size: 15px;
    margin-bottom: 4px;
  }
  .info {
    font-size: 13px;
    color: var(--text-muted);
  }
  .actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }
  button {
    background: var(--accent);
    color: white;
    border: none;
    padding: 6px 14px;
    border-radius: 8px;
    font-size: 13px;
    cursor: pointer;
    font-family: inherit;
    transition: background 0.15s;
  }
  button:hover {
    background: var(--accent-hover);
  }
  button.secondary {
    background: var(--bg-secondary);
    color: var(--text);
  }
  button.secondary:hover {
    background: var(--bg-secondary-hover);
  }
  .busy-bar {
    display: flex;
    gap: 10px;
    align-items: center;
    color: var(--text-muted);
    font-size: 14px;
    padding: 4px 0;
  }
  .spinner {
    width: 14px;
    height: 14px;
    border: 2px solid var(--border);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
  }
  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
</style>
