# End-to-End Testing Walkthrough

Everything in this project has been tested at the unit/integration level (42 passing backend
tests, a clean strict-mode TypeScript build across all 6 frontend routes). What hasn't been
tested — because it needs a GPU/CPU, a real video file, and downloaded model weights that don't
exist in the environment this was built in — is the actual pipeline: upload a real video and get
back a real captioned MP4. This is that walkthrough.

## 1. Install and start

Follow `INSTALLATION.md`, then:

```bash
./start.sh        # or start.bat on Windows
```

Confirm both open without errors:
- Backend: http://localhost:8000/api/system should return JSON with your device info.
- Frontend: http://localhost:3000 should show the dashboard with System Status populated.

## 2. First transcription — expect friction here

The first time you generate captions, `faster-whisper` will download model weights (small ≈
500MB, medium ≈ 1.5GB, large ≈ 3GB). This can take several minutes and is the most likely place
to hit an environment-specific issue (proxy/firewall blocking huggingface.co, insufficient disk
space, etc.) — none of that can be caught by unit tests.

**Test with a short (10–30s) clip first**, not a long video, so failures are fast to diagnose.

Watch the processing stages in the UI. If it errors:
- Check `backend/logs/` and the terminal running uvicorn for the actual traceback.
- Confirm `ffmpeg -version` works from the same shell the backend runs in.
- If CUDA was expected but device shows `cpu`, run `python -c "import torch; print(torch.cuda.is_available())"` inside the backend venv to isolate whether it's a PyTorch/driver mismatch.

## 3. Things worth specifically checking once transcription succeeds

- **Word timestamps look plausible** — words roughly line up with when they're spoken when you
  scrub the video. (This is where WhisperX alignment quality varies most by audio quality.)
- **Hinglish/mixed-language text isn't translated** — if you test with code-switched audio,
  confirm the transcript preserves it as spoken rather than normalizing to one language.
- **Low-confidence word highlighting** in the transcript editor — say something mumbled or
  overlapping and confirm it gets flagged.
- **Video preview word-highlight sync** — does the active word actually track playback smoothly,
  or is there a noticeable lag? (The sync logic runs on the browser's `timeupdate` event, which
  fires roughly every 250ms — fine for most captions but worth eyeballing.)

## 4. Rendering

Once you're happy with the transcript and a style, hit Export → Export Video. This is the other
place real behavior can diverge from what static testing can verify:

- Confirm the burned-in captions are actually legible and positioned correctly at your chosen
  resolution (the style engine scales font size proportionally to canvas height — worth
  double-checking at both 1080p and 4K if you use both).
- Confirm word-level karaoke highlighting (for karaoke-category styles) actually animates in the
  rendered MP4, not just in the browser preview — this depends on ffmpeg's `ass` filter
  interpreting the `\k` tags correctly, which varies slightly by ffmpeg build.
- Time the render. The spec's performance section wants an ETA estimate — that's not implemented
  yet, so note in the export panel whether it feels like it's needed for videos you actually use.

## 5. Report back

If you hit issues, the most useful things to capture are:
1. The exact error message/traceback from the backend terminal.
2. `backend/app/services/transcription_service.py`'s `detect_device()` output — run it directly:
   ```bash
   python -c "from app.services.transcription_service import detect_device; print(detect_device())"
   ```
3. Whether the failure is in transcription, segmentation, or rendering — that narrows which
   service to look at.

Any of those, paste back and I can fix the actual bug rather than guessing at one.
