# Architecture

## Pipeline

Video -> ffmpeg audio extraction -> faster-whisper (VAD + transcription)
-> WhisperX word alignment -> optional pyannote diarization -> segmentation engine
-> style engine -> SRT/VTT/ASS generation -> ffmpeg ASS burn-in render

## Data model

Project -> Transcript -> Segment[] -> Word[]
Project -> ProjectSettings (language, mode, model size, device, style_id, ...)

## Style engine

Every caption style is a `CaptionStyle` dataclass (backend/app/styles/registry.py) — a pure data
object, never hard-coded into a UI component. The ASS generator and (future) frontend style
customizer both read from the same registry, so adding a style requires no other code changes.

## Why FastAPI + Next.js

FastAPI: async-friendly, first-class Pydantic validation, SSE support for processing progress.
Next.js/React/TypeScript/Tailwind: matches the "professional video editor" UI requirement with a
component-based architecture (VideoPreview, CaptionTimeline, TranscriptEditor, StyleLibrary, etc.)
