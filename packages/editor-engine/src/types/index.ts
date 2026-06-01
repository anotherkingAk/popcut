export type TrackType = 'video' | 'audio' | 'text' | 'effect' | 'overlay'

export type BlendMode =
  | 'normal' | 'multiply' | 'screen' | 'overlay'
  | 'darken' | 'lighten' | 'difference' | 'exclusion'

export interface TimelineProject {
  id: string
  name: string
  width: number
  height: number
  fps: number
  duration: number
  tracks: Track[]
  createdAt: number
  updatedAt: number
}

export interface Track {
  id: string
  type: TrackType
  name: string
  index: number
  enabled: boolean
  locked: boolean
  clips: Clip[]
}

export interface Clip {
  id: string
  type: TrackType
  name: string
  sourcePath?: string
  startTime: number
  endTime: number
  duration: number
  offset: number
  speed: number
  volume: number
  opacity: number
  blendMode: BlendMode
  effects: Effect[]
  keyframes: Keyframe[]
  crop?: CropRect
  transform?: Transform
}

export interface CropRect {
  x: number
  y: number
  width: number
  height: number
}

export interface Transform {
  positionX: number
  positionY: number
  scaleX: number
  scaleY: number
  rotation: number
}

export interface Effect {
  id: string
  type: string
  name: string
  enabled: boolean
  params: Record<string, number | string | boolean>
}

export interface Keyframe {
  id: string
  property: string
  time: number
  value: number
  easing: EasingType
}

export type EasingType = 'linear' | 'easeIn' | 'easeOut' | 'easeInOut' | 'bounce' | 'elastic'

export interface ExportConfig {
  format: 'mp4' | 'mov' | 'webm' | 'gif'
  resolution: ResolutionPreset
  fps: number
  bitrate: number
  codec: string
  quality: number
  watermark?: boolean
}

export type ResolutionPreset = '720p' | '1080p' | '4k' | '8k'

export const RESOLUTIONS: Record<ResolutionPreset, { width: number; height: number }> = {
  '720p': { width: 1280, height: 720 },
  '1080p': { width: 1920, height: 1080 },
  '4k': { width: 3840, height: 2160 },
  '8k': { width: 7680, height: 4320 },
}
