export function formatTime(seconds: number, fps: number = 30): string {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  const frames = Math.floor((seconds % 1) * fps)
  return `${pad(mins)}:${pad(secs)}:${pad(frames)}`
}

function pad(num: number, size: number = 2): string {
  return num.toString().padStart(size, '0')
}

export function frameToTime(frame: number, fps: number): number {
  return frame / fps
}

export function timeToFrame(seconds: number, fps: number): number {
  return Math.floor(seconds * fps)
}

export function durationString(seconds: number): string {
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = Math.floor(seconds % 60)
  if (h > 0) return `${h}:${pad(m)}:${pad(s)}`
  return `${m}:${pad(s)}`
}
