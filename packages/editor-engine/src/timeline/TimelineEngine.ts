import { BehaviorSubject, Subject } from 'rxjs'
import type { TimelineProject, Track, Clip } from '../types'

export class TimelineEngine {
  private project$ = new BehaviorSubject<TimelineProject | null>(null)
  private currentTime$ = new BehaviorSubject<number>(0)
  private isPlaying$ = new BehaviorSubject<boolean>(false)
  private selectedClipId$ = new BehaviorSubject<string | null>(null)
  readonly timeChange$ = new Subject<number>()
  readonly clipChange$ = new Subject<Clip>()

  get project(): TimelineProject | null {
    return this.project$.value
  }

  get currentTime(): number {
    return this.currentTime$.value
  }

  get isPlaying(): boolean {
    return this.isPlaying$.value
  }

  get selectedClipId(): string | null {
    return this.selectedClipId$.value
  }

  loadProject(project: TimelineProject): void {
    this.project$.next(project)
    this.currentTime$.next(0)
  }

  seek(time: number): void {
    const project = this.project$.value
    if (!project) return
    const clamped = Math.max(0, Math.min(time, project.duration))
    this.currentTime$.next(clamped)
    this.timeChange$.next(clamped)
  }

  play(): void {
    if (!this.project$.value) return
    this.isPlaying$.next(true)
  }

  pause(): void {
    this.isPlaying$.next(false)
  }

  togglePlay(): void {
    if (this.isPlaying$.value) this.pause()
    else this.play()
  }

  addTrack(track: Track): void {
    const project = this.project$.value
    if (!project) return
    project.tracks.push(track)
    this.project$.next({ ...project })
  }

  removeTrack(trackId: string): void {
    const project = this.project$.value
    if (!project) return
    project.tracks = project.tracks.filter(t => t.id !== trackId)
    this.project$.next({ ...project })
  }

  addClip(trackId: string, clip: Clip): void {
    const project = this.project$.value
    if (!project) return
    const track = project.tracks.find(t => t.id === trackId)
    if (!track) return
    track.clips.push(clip)
    track.clips.sort((a, b) => a.startTime - b.startTime)
    this.project$.next({ ...project })
    this.clipChange$.next(clip)
  }

  removeClip(clipId: string): void {
    const project = this.project$.value
    if (!project) return
    for (const track of project.tracks) {
      track.clips = track.clips.filter(c => c.id !== clipId)
    }
    this.project$.next({ ...project })
  }

  updateClip(clipId: string, updates: Partial<Clip>): void {
    const project = this.project$.value
    if (!project) return
    for (const track of project.tracks) {
      const clip = track.clips.find(c => c.id === clipId)
      if (clip) {
        Object.assign(clip, updates)
        this.clipChange$.next(clip)
      }
    }
    this.project$.next({ ...project })
  }

  splitClip(clipId: string, time: number): Clip | null {
    const project = this.project$.value
    if (!project) return null

    for (const track of project.tracks) {
      const idx = track.clips.findIndex(c => c.id === clipId)
      if (idx === -1) continue
      const clip = track.clips[idx]
      if (time <= clip.startTime || time >= clip.endTime) return null

      const rightPart: Clip = {
        ...JSON.parse(JSON.stringify(clip)),
        id: `${clip.id}_split_${Date.now()}`,
        startTime: time,
        offset: clip.offset + (time - clip.startTime),
        duration: clip.endTime - time,
      }
      clip.endTime = time
      clip.duration = time - clip.startTime

      track.clips.splice(idx + 1, 0, rightPart)
      this.project$.next({ ...project })
      return rightPart
    }
    return null
  }

  onProject(): BehaviorSubject<TimelineProject | null> {
    return this.project$
  }

  onTime(): BehaviorSubject<number> {
    return this.currentTime$
  }

  onPlayState(): BehaviorSubject<boolean> {
    return this.isPlaying$
  }

  selectClip(clipId: string | null): void {
    this.selectedClipId$.next(clipId)
  }

  destroy(): void {
    this.project$.complete()
    this.currentTime$.complete()
    this.isPlaying$.complete()
    this.selectedClipId$.complete()
    this.timeChange$.complete()
    this.clipChange$.complete()
  }
}
