from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uuid
from typing import Optional

app = FastAPI(title="CapCard AI Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class CaptionRequest(BaseModel):
    video_id: str
    language: str = "en"

class CaptionResponse(BaseModel):
    segments: list[dict]
    full_text: str

class GenerateVideoRequest(BaseModel):
    prompt: str
    duration: int = 5
    resolution: str = "1080p"

@app.get("/health")
async def health():
    return {"status": "ok", "service": "ai-service"}

@app.post("/ai/captions", response_model=CaptionResponse)
async def generate_captions(request: CaptionRequest):
    return CaptionResponse(
        segments=[
            {"start": 0.0, "end": 2.5, "text": "Welcome to CapCard Pro"},
            {"start": 2.5, "end": 5.0, "text": "AI-powered video editing"},
        ],
        full_text="Welcome to CapCard Pro. AI-powered video editing."
    )

@app.post("/ai/transcribe")
async def transcribe_audio(file: UploadFile = File(...)):
    return {
        "text": "Transcribed text would appear here",
        "segments": [],
        "duration": 0.0,
    }

@app.post("/ai/generate/video")
async def generate_video(request: GenerateVideoRequest):
    return {
        "job_id": str(uuid.uuid4()),
        "status": "queued",
        "estimated_time": 120,
    }

@app.post("/ai/voice-clone")
async def voice_clone(file: UploadFile = File(...), text: str = ""):
    return {
        "job_id": str(uuid.uuid4()),
        "status": "queued",
        "audio_url": None,
    }

@app.post("/ai/thumbnail")
async def generate_thumbnail(file: UploadFile = File(...)):
    return {
        "url": None,
        "alternatives": [],
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
