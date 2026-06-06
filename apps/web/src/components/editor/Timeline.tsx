'use client'

import React, { useRef, useState } from 'react'
import { Button } from '@/components/ui/button'
import {
  Plus, ZoomIn, ZoomOut, AlignJustify, Music, Type,
  Layers, Image, Film,
} from 'lucide-react'
import { useEditor } from '@/hooks/useEditor'

const RULER_HEIGHT = 28
const TRACK_HEIGHT = 48
const PIXELS_PER_SECOND = 10

export function Timeline() {
  const { currentTime, zoom, zoomIn, zoomOut, seek } = useEditor()
  const containerRef = useRef<HTMLDivElement>(null)
  const [tracks] = useState([
    { id: 'v1', name: 'Video 1', type: 'video', clips: [{ id: 'c1', start: 0, duration: 15, name: 'Clip 1' }] },
    { id: 'v2', name: 'Video 2', type: 'video', clips: [{ id: 'c2', start: 5, duration: 10, name: 'Clip 2' }] },
    { id: 'a1', name: 'Audio 1', type: 'audio', clips: [{ id: 'c3', start: 0, duration: 20, name: 'Background Music' }] },
  ])
  const totalDuration = 30

  const pixelsPerSecond = PIXELS_PER_SECOND * zoom
  const totalWidth = totalDuration * pixelsPerSecond

  const rulerMarks = Array.from({ length: Math.ceil(totalDuration) + 1 }, (_, i) => i)

  const RulerMark = React.memo(({ mark, pps }: { mark: number; pps: number }) => (
    <div
      className="absolute top-0 h-full border-l border-border"
      style={{ left: mark * pps }}
    >
      <span className="text-[10px] text-text-muted ml-1">
        {String(Math.floor(mark / 60)).padStart(2, '0')}:{String(mark % 60).padStart(2, '0')}
      </span>
    </div>
  ))

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
              <div
                key={track.id}
                className="flex items-center gap-2 px-3 border-r border-b border-border"
                style={{ height: TRACK_HEIGHT }}
              >
                <div className={`w-2 h-2 rounded-full ${track.type === 'video' ? 'bg-primary' : 'bg-accent'}`} />
                <span className="text-xs text-text-secondary truncate w-20">{track.name}</span>
              </div>
            ))}
            <div className="h-8 border-r border-border" />
          </div>

          <div className="flex-1 overflow-x-auto scrollbar-thin">
            <div
              className="relative"
              style={{ width: totalWidth, minWidth: '100%' }}
            >
              <div className="relative h-7 border-b border-border bg-background">
                {rulerMarks.map((mark) => (
                  <RulerMark key={mark} mark={mark} pps={pixelsPerSecond} />
                ))}

                <div
                  className="absolute top-0 w-px h-full bg-primary z-10 pointer-events-none"
                  style={{ left: currentTime * pixelsPerSecond }}
                >
                  <div className="w-2.5 h-2.5 bg-primary rounded-sm -ml-[5px] -mt-[1px]" />
                </div>
              </div>

              {tracks.map((track) => (
                <div key={track.id} className="relative" style={{ height: TRACK_HEIGHT }}>
                  {track.clips.map((clip) => (
                    <div
                      key={clip.id}
                      className="absolute top-1 bottom-1 rounded-md bg-primary/20 border border-primary/30 px-2 flex items-center cursor-pointer hover:bg-primary/30 transition-colors"
                      style={{
                        left: clip.start * pixelsPerSecond,
                        width: clip.duration * pixelsPerSecond,
                      }}
                    >
                      <span className="text-xs text-primary truncate">{clip.name}</span>
                    </div>
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
}
