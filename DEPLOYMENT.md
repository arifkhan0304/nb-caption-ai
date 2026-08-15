# Deployment: GitHub → Live URL

This covers pushing the project to GitHub and deploying it so it's reachable at a real URL.
Two paths are documented — pick one.

## Before you deploy: set a password

This app has no login system by design (local-first, personal use). If you're putting it on the
public internet, set `APP_PASSWORD` (see below) so random visitors can't upload videos, burn
your compute, or read/delete your projects. Pick something long and random — this is the only
thing standing between your instance and the open internet.

---

## Path A — Render Blueprint (easiest, one dashboard, both services)

**What you get:** backend + frontend both running as Docker web services, a persistent disk for
uploads/projects/exports, HTTPS and a `*.onrender.com` URL automatically. Render's standard plans
are CPU-only — fine for personal use, slower than GPU hosting for the `large` Whisper model.

### 1. Push to GitHub

```bash
cd nb-caption-ai
git init
git add .
git commit -m "Initial commit"
gh repo create nb-caption-ai --private --source=. --push
# or manually: create a repo on github.com, then
# git remote add origin https://github.com/YOUR_USERNAME/nb-caption-ai.git
# git push -u origin main
```

### 2. Deploy via Blueprint

1. Go to https://dashboard.render.com → **New +** → **Blueprint**.
2. Connect your GitHub account and pick the `nb-caption-ai` repo. Render reads `render.yaml`
   automatically and shows both services it's about to create.
3. Before clicking deploy, Render will prompt for the `APP_PASSWORD` value (marked `sync: false`
   in the blueprint so it's never committed to the repo) — enter your password there.
4. Click **Apply**. Render builds both Docker images and deploys them. First build takes a few
   minutes.

### 3. Fix the cross-service URLs

`render.yaml` guesses your service URLs (`nb-caption-ai-backend.onrender.com` etc.), which is
usually right if those names aren't taken, but double-check once both services are live:

- Open the **frontend** service → Environment → confirm `NEXT_PUBLIC_API_URL` matches your
  actual backend URL. If you change it, trigger a manual redeploy (this var is baked in at
  build time, so just changing the env var isn't enough — it needs a rebuild).
- Open the **backend** service → Environment → confirm `FRONTEND_ORIGIN` matches your actual
  frontend URL (needed for CORS to allow the frontend to call the API).

### 4. First run

Visit your frontend URL, enter the password you set, and try a short test clip. The **first**
transcription will be slow — it's downloading Whisper model weights (500MB–3GB depending on
model size) onto the persistent disk. Subsequent runs are fast.

---

## Path B — Split: Vercel (frontend) + any server (backend)

Vercel is excellent for the Next.js frontend but its serverless functions aren't suited to a
long-running FastAPI process with heavy ML dependencies (faster-whisper/whisperx/torch). Use
Vercel only for the frontend, and run the backend somewhere with a real, persistent process —
a VPS (see below), Render (Path A, backend service only), Railway, or a GPU host if you want fast
`large`-model transcription.

### Frontend on Vercel

1. Push to GitHub (same as Path A step 1).
2. https://vercel.com → **Add New** → **Project** → import the repo.
3. Set **Root Directory** to `frontend`.
4. Add environment variable `NEXT_PUBLIC_API_URL` = your backend's URL.
5. Deploy.

### Backend on a VPS (Hetzner, DigitalOcean, etc.)

```bash
# on the server
git clone https://github.com/YOUR_USERNAME/nb-caption-ai.git
cd nb-caption-ai/backend
docker build -f ../docker/Dockerfile.backend -t nb-caption-backend .
docker run -d -p 8000:8000 \
  -e APP_PASSWORD=your-password-here \
  -e FRONTEND_ORIGIN=https://your-app.vercel.app \
  -v $(pwd)/projects:/app/projects \
  -v $(pwd)/uploads:/app/uploads \
  -v $(pwd)/exports:/app/exports \
  -v $(pwd)/models:/app/models \
  --name nb-caption-backend \
  nb-caption-backend
```

Put nginx + certbot in front for HTTPS on a real domain (see the snippet in the README's earlier
deployment notes), since Vercel's frontend will refuse to call an `http://` backend from an
`https://` page (mixed content).

---

## Updating after the first deploy

Both Render and Vercel auto-deploy on every push to `main`:

```bash
git add .
git commit -m "your change"
git push
```

CI (`.github/workflows/ci.yml`) runs the backend test suite and a frontend production build on
every push — check the Actions tab on GitHub if a deploy fails, since CI will usually have
caught the same failure first.

## Costs (rough, as of writing — verify current pricing)

- Render: backend `standard` plan (~$25/mo) + frontend `starter` (~$7/mo) + disk (~$0.25/GB/mo).
  A free-tier deploy is possible but will be too slow/resource-constrained for real transcription.
- Vercel: frontend hosting is free for personal projects.
- VPS: $10–40/mo depending on provider/specs (CPU-only; GPU boxes cost significantly more but
  aren't necessary unless you want fast `large`-model transcription for regular use).
