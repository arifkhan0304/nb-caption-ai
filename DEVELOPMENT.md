# Development

## Run backend tests (once test suite is added)
```
cd backend && pytest
```

## Manually verify the style/segmentation/subtitle pipeline (no GPU needed)
```python
from app.models.schemas import Word
from app.services.segmentation_service import segment_words
from app.services.subtitle_generator import generate_srt

words = [Word(text=w, start=i*0.4, end=i*0.4+0.35) for i, w in enumerate("your transcript here".split())]
segments = segment_words(words, "normal")
print(generate_srt(segments))
```

## Code style
- Backend: Python type hints + Pydantic models throughout.
- Frontend: TypeScript strict mode.
- No hardcoded secrets. No paid API calls anywhere in the codebase.
