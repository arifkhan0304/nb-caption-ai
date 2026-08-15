# Installation

## Prerequisites

- Python 3.10–3.11
- Node.js 18+
- FFmpeg on PATH
- (Optional, for GPU acceleration) NVIDIA GPU with CUDA 12.x + matching drivers

### FFmpeg

- **Windows:** `winget install ffmpeg` (or download from ffmpeg.org and add to PATH)
- **macOS:** `brew install ffmpeg`
- **Linux (Debian/Ubuntu):** `sudo apt-get install ffmpeg`

## Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

GPU users: install the CUDA build of PyTorch matching your CUDA version, e.g.:

```bash
pip install torch --index-url https://download.pytorch.org/whl/cu121
```

Start the backend:

```bash
uvicorn app.main:app --reload --port 8000
```

## Frontend

```bash
cd frontend
npm install
npm run dev
```

Visit http://localhost:3000

## One-command start

```bash
# Windows
start.bat

# Linux / macOS
./start.sh
```

## Optional: speaker diarization

Diarization uses `pyannote.audio`, which requires a free Hugging Face account and accepting the
model license at https://huggingface.co/pyannote/speaker-diarization-3.1. Inference still runs
entirely on your machine — the token is only used once to download model weights.

```
HF_TOKEN=hf_xxx   # in your .env
ENABLE_DIARIZATION=true
```

## Docker (optional)

```bash
docker compose up --build
```

Docker is not required — the scripts above are the primary supported path.
