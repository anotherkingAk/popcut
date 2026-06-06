'use client'

import React, { useRef, useState, useMemo, useEffect, useCallback } from 'react'
import { Button } from '@/components/ui/button'
import {
  Plus, ZoomIn, ZoomOut, AlignJustify, Music, Type,
  Layers, Image, Film,
} from 'lucide-react'
import { useCurrentTime, useZoom, useEditorActions } from '@/hooks/useEditor'

const RULER_HEIGHT = 28
const TRACK_HEIGHT = 48
const PIXELS_PER_SECOND = 10
const RULER_SEGMENT_SIZE = 10

const RulerMark = React.memo(({ mark, pps }: { mark: number; pps: number }) => (
  <div className="absolute top-0 h-full border-l border-border" style={{ left: mark * pps }}>
    <span className="text-[10px] text-text-muted ml-1">
      {String(Math.floor(mark / 60)).padStart(2, '0')}:{String(mark % 60).padStart(2, '0')}
    </span>
  </div>
))

const Playhead = React.memo(({ left }: { left: number }) => (
  <div className="absolute top-0 w-px h-full bg-primary z-10 pointer-events-none" style={{ left }}>
    <div className="w-2.5 h-2.5 bg-primary rounded-sm -ml-[5px] -mt-[1px]" />
  </div>
))

const TrackLabel = React.memo(({ track }: { track: { id: string; name: string; type: string } }) => (
  <div className="flex items-center gap-2 px-3 border-r border-b border-border" style={{ height: TRACK_HEIGHT }}>
    <div className={`w-2 h-2 rounded-full ${track.type === 'video' ? 'bg-primary' : 'bg-accent'}`} />
    <span className="text-xs text-text-secondary truncate w-20">{track.name}</span>
  </div>
))

const ClipItem = React.memo(({ clip, pps }: { clip: { id: string; start: number; duration: number; name: string }; pps: number }) => (
  <div
    className="absolute top-1 bottom-1 rounded-md bg-primary/20 border border-primary/30 px-2 flex items-center cursor-pointer hover:bg-primary/30 transition-colors"
    style={{ left: clip.start * pps, width: clip.duration * pps }}
  >
    <span className="text-xs text-primary truncate">{clip.name}</span>
  </div>
))

export const Timeline = React.memo(function Timeline() {
  const currentTime = useCurrentTime()
  const zoom = useZoom()
  const { seek, zoomIn, zoomOut } = useEditorActions()
  const containerRef = useRef<HTMLDivElement>(null)
  const rulerRef = useRef<HTMLDivElement>(null)
  const [scrollLeft, setScrollLeft] = useState(0)
  const [containerWidth, setContainerWidth] = useState(800)

  const [tracks] = useState([
    { id: 'v1', name: 'Video 1', type: 'video', clips: [{ id: 'c1', start: 0, duration: 15, name: 'Clip 1' }] },
    { id: 'v2', name: 'Video 2', type: 'video', clips: [{ id: 'c2', start: 5, duration: 10, name: 'Clip 2' }] },
    { id: 'a1', name: 'Audio 1', type: 'audio', clips: [{ id: 'c3', start: 0, duration: 20, name: 'Background Music' }] },
  ])
  const totalDuration = 30

  const pixelsPerSecond = PIXELS_PER_SECOND * zoom
  const totalWidth = totalDuration * pixelsPerSecond

  useEffect(() => {
    const el = containerRef.current
    if (!el) return
    const observer = new ResizeObserver(entries => {
      setContainerWidth(entries[0].contentRect.width)
    })
    observer.observe(el)
    return () => observer.disconnect()
  }, [])

  const handleScroll = useCallback(() => {
    if (rulerRef.current) setScrollLeft(rulerRef.current.scrollLeft)
  }, [])

  // Virtualized ruler: only render marks visible in the viewport
  const visibleMarks = useMemo(() => {
    const totalMarks = Math.ceil(totalDuration) + 1
    if (totalMarks === 0) return []

    const startSecond = Math.max(0, Math.floor(scrollLeft / pixelsPerSecond) - 2)
    const endSecond = Math.min(totalMarks, Math.ceil((scrollLeft + containerWidth) / pixelsPerSecond) + 2)

    const marks: number[] = []
    for (let i = startSecond; i < endSecond; i++) {
      marks.push(i)
    }
    return marks
  }, [scrollLeft, containerWidth, pixelsPerSecond, totalDuration])

  return (
    <div className="h-72 bg-surface border-t border-border flex flex-col shrink-0">
      <div className="h-10 border-b border-border flex items-center justify-between px-4 shrink-0">
        <div className="flex items-center gap-1">
          <Button variant="ghost" size="sm">
            <Film className="w-4 h-4 mr-1.5" />
            Timeline
          </Button>
          <Button variant="ghost" size="icon" className="w-7 h-7">
            <Music className="w-3.5 h-3.5" />
          </Button>
          <Button variant="ghost" size="icon" className="w-7 h-7">
            <Type className="w-3.5 h-3.5" />
          </Button>
          <Button variant="ghost" size="icon" className="w-7 h-7">
            <Image className="w-3.5 h-3.5" />
          </Button>
          <Button variant="ghost" size="icon" className="w-7 h-7">
            <Layers className="w-3.5 h-3.5" />
          </Button>
        </div>

        <div className="flex items-center gap-1">
          <Button variant="ghost" size="icon" className="w-7 h-7" onClick={zoomOut}>
            <ZoomOut className="w-3.5 h-3.5" />
          </Button>
          <span className="text-xs text-text-muted w-8 text-center">{Math.round(zoom * 100)}%</span>
          <Button variant="ghost" size="icon" className="w-7 h-7" onClick={zoomIn}>
            <ZoomIn className="w-3.5 h-3.5" />
          </Button>
        </div>
      </div>

      <div className="flex-1 overflow-auto scrollbar-thin" ref={containerRef}>
        <div className="flex">
          <div className="shrink-0">
            {tracks.map((track) => (
              <TrackLabel key={track.id} track={track} />
            ))}
            <div className="h-8 border-r border-border" />
          </div>

          <div
            className="flex-1 overflow-x-auto scrollbar-thin"
            ref={rulerRef}
            onScroll={handleScroll}
          >
            <div className="relative" style={{ width: totalWidth, minWidth: '100%' }}>
              <div className="relative h-7 border-b border-border bg-background">
                {visibleMarks.map((mark) => (
                  <RulerMark key={mark} mark={mark} pps={pixelsPerSecond} />
                ))}
                <Playhead left={currentTime * pixelsPerSecond} />
              </div>

              {tracks.map((track) => (
                <div key={track.id} className="relative" style={{ height: TRACK_HEIGHT }}>
                  {track.clips.map((clip) => (
                    <ClipItem key={clip.id} clip={clip} pps={pixelsPerSecond} />
                  ))}
                </div>
              ))}

              <div className="h-8 border-t border-border" />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
})
