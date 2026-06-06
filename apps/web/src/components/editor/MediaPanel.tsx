'use client'

import React from 'react'
import { Button } from '@/components/ui/button'
import { Upload, Image, Music, FileVideo, Search } from 'lucide-react'

const mediaItems = [
  { id: 'm1', name: 'beach_vlog.mp4', type: 'video', duration: '00:45' },
  { id: 'm2', name: 'intro_music.mp3', type: 'audio', duration: '02:30' },
  { id: 'm3', name: 'logo.png', type: 'image' },
  { id: 'm4', name: 'overlay.mov', type: 'video', duration: '00:12' },
]

const MediaItem = React.memo(({ item }: { item: typeof mediaItems[0] }) => (
  <div className="flex items-center gap-2.5 p-2 rounded-lg hover:bg-surface-hover cursor-pointer transition-colors group">
    <div className="w-10 h-10 rounded-md bg-surface-hover flex items-center justify-center shrink-0">
      {item.type === 'video' && <FileVideo className="w-4 h-4 text-primary" />}
      {item.type === 'audio' && <Music className="w-4 h-4 text-accent" />}
      {item.type === 'image' && <Image className="w-4 h-4 text-success" />}
    </div>
    <div className="min-w-0">
      <p className="text-xs text-text truncate">{item.name}</p>
      {item.duration && (
        <p className="text-[10px] text-text-muted">{item.duration}</p>
      )}
    </div>
  </div>
))

export function MediaPanel() {
  return (
    <div className="w-60 bg-surface border-r border-border flex flex-col shrink-0">
      <div className="h-10 border-b border-border flex items-center justify-between px-3">
        <span className="text-xs font-medium text-text">Media</span>
        <Button variant="ghost" size="icon" className="w-6 h-6">
          <Upload className="w-3.5 h-3.5" />
        </Button>
      </div>

      <div className="p-2">
        <div className="relative">
          <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-text-muted" />
          <input
            placeholder="Search media..."
            className="w-full h-8 rounded-md bg-background pl-8 pr-2 text-xs text-text placeholder:text-text-muted outline-none border border-border focus:border-primary"
          />
        </div>
      </div>

      <div className="flex gap-1 px-2 mb-2">
        <button className="flex items-center gap-1 px-2 py-1 rounded text-xs bg-primary/10 text-primary">
          <FileVideo className="w-3 h-3" />
          All
        </button>
        <button className="flex items-center gap-1 px-2 py-1 rounded text-xs text-text-secondary hover:bg-surface-hover">
          <Image className="w-3 h-3" />
          Images
        </button>
        <button className="flex items-center gap-1 px-2 py-1 rounded text-xs text-text-secondary hover:bg-surface-hover">
          <Music className="w-3 h-3" />
          Audio
        </button>
      </div>

      <div className="flex-1 overflow-y-auto px-2 space-y-1 scrollbar-thin">
        {mediaItems.map((item) => (
          <MediaItem key={item.id} item={item} />
        ))}
      </div>
    </div>
  )
}
