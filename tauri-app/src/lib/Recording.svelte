<script lang="ts">
  import {
    type Recording,
    transcribe,
    summarize,
    exportFile,
    openInFinder,
  } from "./api";
  import {
    STATUS_LABELS,
    ACTIONS,
    formatDurationFriendly,
    formatDateFriendly,
    friendlyError,
  } from "./strings";

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
      alert(friendlyError(String(e)));
    } finally {
      busy = false;
      busyMessage = "";
    }
  }

  $: status = STATUS_LABELS[rec.status];
  $: dateLabel = formatDateFriendly(rec.date);
  $: durationLabel = formatDurationFriendly(rec.duration_secs);
</script>

<div class="recording" class:busy>
  <div class="header">
    <div class="status-badge" style="--status-color: {status.color}">
      <span class="emoji">{status.emoji}</span>
      <span class="label">{status.label}</span>
    </div>
    <div class="meta-line">
      {#if dateLabel}<span>{dateLabel}</span>{/if}
      {#if rec.time && rec.time !== "—"}<span>{rec.time}</span>{/if}
      <span>·</span>
      <span>{durationLabel}</span>
    </div>
  </div>

  <div class="title" title={rec.path}>{rec.name}</div>

  {#if status.hint}
    <div class="hint">{status.hint}</div>
  {/if}

  {#if busy}
    <div class="busy-bar">
      <div class="spinner" />
      <span>{busyMessage}</span>
    </div>
  {:else}
    <div class="actions">
      {#if rec.status === "raw"}
        <button
          class="primary"
          title={ACTIONS.transcribe.hint}
          on:click={() =>
            run(ACTIONS.transcribe.busy, () => transcribe(rec.path))}
        >
          {ACTIONS.transcribe.label}
        </button>
        <button
          class="secondary"
          title={ACTIONS.openFolder.hint}
          on:click={() => openInFinder(rec.path)}
        >
          {ACTIONS.openFolder.label}
        </button>
      {:else if rec.status === "transcribed" && rec.transcript_path}
        <button
          class="primary"
          title={ACTIONS.summarize.hint}
          on:click={() =>
            run(ACTIONS.summarize.busy, () =>
              summarize(rec.transcript_path!, "protocol"),
            )}
        >
          {ACTIONS.summarize.label}
        </button>
        <button
          class="secondary"
          title={ACTIONS.viewTranscript.hint}
          on:click={() => openInFinder(rec.transcript_path!)}
        >
          {ACTIONS.viewTranscript.label}
        </button>
        <button
          class="ghost"
          title={ACTIONS.retranscribe.hint}
          on:click={() =>
            run(ACTIONS.retranscribe.busy, () => transcribe(rec.path))}
        >
          {ACTIONS.retranscribe.label}
        </button>
      {:else if rec.status === "summarized" && rec.summary_path}
        <button
          class="primary"
          title={ACTIONS.exportPdf.hint}
          on:click={() =>
            run(ACTIONS.exportPdf.busy, () =>
              exportFile(rec.summary_path!, "pdf"),
            )}
        >
          {ACTIONS.exportPdf.label}
        </button>
        <button
          class="secondary"
          title={ACTIONS.viewSummary.hint}
          on:click={() => openInFinder(rec.summary_path!)}
        >
          {ACTIONS.viewSummary.label}
        </button>
        <button
          class="ghost"
          title={ACTIONS.resummarize.hint}
          on:click={() =>
            run(ACTIONS.resummarize.busy, () =>
              summarize(rec.transcript_path!, "protocol"),
            )}
        >
          {ACTIONS.resummarize.label}
        </button>
      {/if}
    </div>
  {/if}
</div>

<style>
  .recording {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 18px 22px;
    margin-bottom: 14px;
    transition: all 0.18s ease;
  }
  .recording:hover {
    border-color: var(--accent);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
  }
  .recording.busy {
    opacity: 0.85;
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
    gap: 12px;
  }

  .status-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 10px;
    border-radius: 999px;
    background: color-mix(in srgb, var(--status-color) 12%, transparent);
    color: var(--status-color);
    font-size: 12px;
    font-weight: 600;
  }
  .status-badge .emoji {
    font-size: 14px;
  }

  .meta-line {
    display: flex;
    gap: 6px;
    font-size: 12px;
    color: var(--text-muted);
    flex-wrap: wrap;
  }

  .title {
    font-weight: 600;
    font-size: 15px;
    margin-bottom: 6px;
    color: var(--text);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .hint {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 12px;
    line-height: 1.4;
  }

  .actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }

  button {
    border: none;
    padding: 8px 16px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    font-family: inherit;
    transition: all 0.15s;
  }
  button:hover {
    transform: translateY(-1px);
  }
  button.primary {
    background: var(--accent);
    color: white;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  }
  button.primary:hover {
    background: var(--accent-hover);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.12);
  }
  button.secondary {
    background: var(--bg-secondary);
    color: var(--text);
  }
  button.secondary:hover {
    background: var(--bg-secondary-hover);
  }
  button.ghost {
    background: transparent;
    color: var(--text-muted);
    padding: 8px 10px;
  }
  button.ghost:hover {
    color: var(--text);
    background: var(--bg-secondary);
  }

  .busy-bar {
    display: flex;
    gap: 10px;
    align-items: center;
    color: var(--text-muted);
    font-size: 14px;
    padding: 6px 0;
  }
  .spinner {
    width: 16px;
    height: 16px;
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
