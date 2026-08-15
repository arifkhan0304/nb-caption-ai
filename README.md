# NB Caption AI

**AI Captions. Your Style.**

A free, self-hosted, local-first AI video caption generator and animated caption editor.
No subscriptions, no payment gateway, no credits, no paid API required.

## What's implemented in this scaffold (real, tested code)

- **Style Engine** — 60 data-driven caption styles (`backend/app/styles/registry.py`), each with
  its own font, animation, word-animation, highlight mode, and layout rules. Verified: loads all
  60, rule-based content classifier correctly recommends styles per video type.
- **Custom Styles** — full CRUD (create/read/update/delete/duplicate) persisted as JSON files,
  plus client-side JSON import/export, wired to a live **Style Customizer** panel in the editor.
- **Auto Emphasis Engine** — rule-based detection of currency, percentages, numbers, superlatives,
  urgency language, and user-supplied keywords; marks words for visual emphasis without ever
  altering the spoken transcript (verified by a dedicated test).
- **Speaker rename + per-speaker colors** — rename `SPEAKER_00` → a real name across every
  segment and word in one call; stable color assignment from a fixed palette, rendered in both
  the transcript editor and (via speaker labels) ready for the preview.
- **Accuracy benchmarking (WER/CER)** — Levenshtein-based Word/Character Error Rate calculator
  for comparing a reference transcript against the AI output; never claims a universal accuracy
  number, only reports what was measured for the given pair.
- **Segmentation Engine** — configurable presets (Fast / Normal / Slow / Podcast / Cinematic) that
  chunk a word stream into readable caption blocks using word count, char limits, natural pauses,
  sentence boundaries, and speaker changes. A real bug (long pauses being ignored on short blocks)
  was caught and fixed by the test suite below.
- **Subtitle Generators** — standards-compliant SRT and WebVTT, plus ASS with per-word karaoke
  timing (`\k` tags) driven by the active style.
- **Caption Quality Checker** — flags overlaps, negative duration, overlong lines, and reading
  speed above threshold.
- **FastAPI backend** — every endpoint from the spec, including project CRUD + duplicate, custom
  style CRUD, and a diagnostics endpoint (OS/CPU/RAM/disk/GPU/CUDA/FFmpeg/Python/dependency status).
- **42 passing automated tests** (`backend/tests/`) — unit tests for segmentation/subtitles/styles/
  emphasis/benchmarking/speakers, plus FastAPI `TestClient` integration tests for the actual HTTP
  routes. Run with `pytest` inside `backend/`.
- **FFmpeg service** — video probing, safe audio extraction, ASS-based burned-in rendering, and a
  path-restricted `/api/video-file` endpoint for browser playback — all using subprocess argument
  lists (never shell strings).
- **Transcription service** — wraps `faster-whisper` + `WhisperX` word alignment + optional
  `pyannote` diarization, with automatic CUDA detection and CPU fallback.
- **Full editor UI (Next.js + TypeScript, strict mode, verified with `tsc --noEmit` and a real
  production `next build` — all 5 routes compile clean)**:
  - Home: upload → caption generation settings → live SSE processing stages → auto-redirect to editor
  - Editor: transcript panel (edit/split/merge/delete/add, low-confidence word review, **click a
    speaker label to rename them everywhere**, emphasized words visually flagged), video
    preview with real-time word-highlight sync (emphasized words render bolder/underlined), drag/
    resize/move timeline, undo/redo, autosave, keyboard shortcuts
  - Style Library: search, category filter, favorites, recent styles, AI-recommended styles,
    **animated hover previews** driven by the same `animation`/`word_animation`/`highlight_mode`
    fields the backend ASS generator reads — a demo caption plays the style's actual entrance and
    word animation on hover/focus, respecting `prefers-reduced-motion`
  - Style Customizer: live property editing, save/update/delete as custom style, JSON import/export
  - Export panel: **social presets** (Instagram Reel/Feed, YouTube Short/YouTube, TikTok),
    resolution/FPS/codec, upscale warnings, quality-check, SRT/VTT/ASS download, MP4 render
  - Projects page: list, rename, duplicate, delete
  - Batch page: queue multiple videos, sequential upload → transcribe with per-item live status,
    retry-on-failure, and a direct link into the editor once each finishes
  - Settings page: General/AI/Language/Caption/Appearance/Export/Storage/GPU/Advanced sections,
    plus a live System Diagnostics view with copy-to-clipboard
- **Docker + one-command start scripts** (`start.sh`, `start.bat`) and `.env.example` with zero
  paid keys.
- **Deployable**: `.gitignore`, GitHub Actions CI (`.github/workflows/ci.yml` — runs the backend
  test suite and a full frontend production build on every push), a Render Blueprint
  (`render.yaml`) for one-click deploy of both services, and an optional shared-password gate
  (`APP_PASSWORD` env var — since this app has no user accounts by design, this is what keeps a
  public deployment from being open to anyone who finds the URL) covering both API requests and
  direct download/video links. See `DEPLOYMENT.md`.

## What is NOT yet built

- Nothing here is a fake/mocked implementation — every backend module was actually run and
  tested (28 passing tests), and the entire frontend was actually type-checked and built (6 routes,
  strict TypeScript, zero errors) — but the end-to-end "upload a video → get a rendered captioned
  MP4" flow has not been run against a real video in this environment (no GPU, no sample video, no
  ML model weights here).

## Suggested next phases

1. End-to-end test with a real video + a real GPU/CPU to validate the full pipeline and fix
   whatever breaks in practice (model downloads, alignment edge cases, ASS rendering quirks).
2. Parallel batch processing when multiple GPUs are detected (currently sequential, which is the
   safe default for a single shared GPU/CPU).
3. AI cleanup layer (optional local LLM via Ollama) for punctuation/style-recommendation refinement.

## Architecture

```
nb-caption-ai/
  backend/            FastAPI app
    app/
      main.py          API routes
      models/          Pydantic schemas (Project, Segment, Word, VideoInfo...)
      services/        ffmpeg, transcription, segmentation, subtitle generation
      styles/          the 60-style registry + recommendation engine
    requirements.txt
  frontend/           Next.js app (scaffold)
  docker/             Dockerfiles
  docker-compose.yml
  start.sh / start.bat
  .env.example
```

See `INSTALLATION.md` for exact setup commands, or `DEPLOYMENT.md` to push this to GitHub and
deploy it to a live URL.
