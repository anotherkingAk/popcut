'use client'

import { Button } from '@/components/ui/button'
import {
  Undo2, Redo2, Scissors, Copy, Trash2,
  Download, Play, Square, Clock,
} from 'lucide-react'

export function EditorToolbar() {
  return (
    <div className="h-12 bg-surface border-b border-border flex items-center justify-between px-4 shrink-0">
      <div className="flex items-center gap-1">
        <Button variant="ghost" size="icon"><Undo2 className="w-4 h-4" /></Button>
        <Button variant="ghost" size="icon"><Redo2 className="w-4 h-4" /></Button>
        <div className="w-px h-6 bg-border mx-1" />
        <Button variant="ghost" size="icon"><Scissors className="w-4 h-4" /></Button>
        <Button variant="ghost" size="icon"><Copy className="w-4 h-4" /></Button>
        <Button variant="ghost" size="icon"><Trash2 className="w-4 h-4" /></Button>
      </div>

      <div className="flex items-center gap-2">
        <span className="text-sm text-text-muted font-mono">00:00:00</span>
        <Button variant="secondary" size="sm">
          <Play className="w-4 h-4 mr-1" />
          Play
        </Button>
        <Button variant="secondary" size="sm">
          <Download className="w-4 h-4 mr-1" />
          Export
        </Button>
      </div>
    </div>
  )
}
