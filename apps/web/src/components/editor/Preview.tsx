'use client'

import React from 'react'
import { Play, Pause, Maximize2, Volume2 } from 'lucide-react'
import { useIsPlaying, useEditorActions } from '@/hooks/useEditor'

export const Preview = React.memo(function Preview() {
  const isPlaying = useIsPlaying()
  const { togglePlay } = useEditorActions()

  return (
    <div className="flex-1 bg-black flex items-center justify-center relative min-h-[300px]">
      <div className="relative">
        <div className="w-[640px] aspect-video bg-[#1a1a1a] rounded-lg flex items-center justify-center border border-border">
          <span className="text-text-muted text-sm">Preview</span>
        </div>

        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex items-center gap-3">
          <button
            onClick={togglePlay}
            className="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
          >
            {isPlaying ? (
              <Pause className="w-4 h-4 text-white" />
            ) : (
              <Play className="w-4 h-4 text-white ml-0.5" />
            )}
          </button>

          <div className="flex items-center gap-2 text-xs text-text-muted font-mono">
            <span>00:00:00</span>
            <span>/</span>
            <span>00:02:00</span>
          </div>

          <div className="flex items-center gap-2">
            <Volume2 className="w-3.5 h-3.5 text-text-muted" />
            <div className="w-20 h-1 bg-border rounded-full overflow-hidden">
              <div className="w-3/4 h-full bg-text-muted rounded-full" />
            </div>
          </div>

          <button className="p-1.5 rounded hover:bg-white/10 transition-colors">
            <Maximize2 className="w-3.5 h-3.5 text-text-muted" />
          </button>
        </div>
      </div>
    </div>
  )
})
