# Troubleshooting

**Backend won't start / ffmpeg not found**
Install ffmpeg and confirm `ffmpeg -version` works in your terminal.

**"faster-whisper is not installed"**
`pip install faster-whisper` inside the backend virtual environment.

**CUDA not detected but I have an NVIDIA GPU**
Confirm `nvidia-smi` works, then install the CUDA-matched PyTorch build (see INSTALLATION.md).
The app falls back to CPU automatically either way — it will not crash.

**Out of VRAM**
Choose a smaller model size in Caption Generation Settings (e.g. `small` instead of `large`).

**Rendering fails**
Check `backend/logs/` for the ffmpeg stderr captured in the error response's `details` field.

**Frontend can't reach backend**
Confirm the backend is running on port 8000 and `NEXT_PUBLIC_API_URL` in the frontend matches.
