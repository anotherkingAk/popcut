'use client'

import React from 'react'
import { Sliders, Palette, Sparkles, Layers } from 'lucide-react'

const tabs = [
  { id: 'adjust', label: 'Adjust', icon: Sliders },
  { id: 'effects', label: 'Effects', icon: Sparkles },
  { id: 'filters', label: 'Filters', icon: Palette },
  { id: 'layers', label: 'Layers', icon: Layers },
]

export const EffectsPanel = React.memo(function EffectsPanel() {
  return (
    <div className="w-60 bg-surface border-l border-border flex flex-col shrink-0">
      <div className="flex border-b border-border">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            className="flex-1 flex flex-col items-center gap-0.5 py-2 text-[10px] text-text-muted hover:text-text hover:bg-surface-hover transition-colors"
          >
            <tab.icon className="w-4 h-4" />
            {tab.label}
          </button>
        ))}
      </div>

      <div className="flex-1 p-3 overflow-y-auto scrollbar-thin">
        <div className="space-y-3">
          <div className="space-y-2">
            <label className="text-xs text-text-secondary">Opacity</label>
            <input
              type="range"
              min="0"
              max="100"
              defaultValue="100"
              className="w-full h-1 bg-border rounded-full appearance-none cursor-pointer [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-3 [&::-webkit-slider-thumb]:h-3 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-primary"
            />
          </div>

          <div className="space-y-2">
            <label className="text-xs text-text-secondary">Blur</label>
            <input
              type="range"
              min="0"
              max="20"
              defaultValue="0"
              className="w-full h-1 bg-border rounded-full appearance-none cursor-pointer [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-3 [&::-webkit-slider-thumb]:h-3 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-primary"
            />
          </div>

          <div className="space-y-2">
            <label className="text-xs text-text-secondary">Speed</label>
            <input
              type="range"
              min="10"
              max="400"
              defaultValue="100"
              className="w-full h-1 bg-border rounded-full appearance-none cursor-pointer [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-3 [&::-webkit-slider-thumb]:h-3 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-primary"
            />
            <span className="text-[10px] text-text-muted">1.0x</span>
          </div>
        </div>
      </div>
    </div>
  )
})
