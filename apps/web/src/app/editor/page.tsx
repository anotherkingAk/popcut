'use client'

import { useEffect } from 'react'
import { TimelineEngine } from '@capcard/editor-engine'
import { useEditorStore } from '@/hooks/useEditor'
import { EditorToolbar } from '@/components/editor/EditorToolbar'
import { Timeline } from '@/components/editor/Timeline'
import { Preview } from '@/components/editor/Preview'
import { MediaPanel } from '@/components/editor/MediaPanel'
import { EffectsPanel } from '@/components/editor/EffectsPanel'

export default function EditorPage() {
  const setEngine = useEditorStore.setState

  useEffect(() => {
    const engine = new TimelineEngine()
    engine.loadProject({
      id: 'new-project',
      name: 'Untitled Project',
      width: 1920,
      height: 1080,
      fps: 30,
      duration: 60,
      tracks: [],
      createdAt: Date.now(),
      updatedAt: Date.now(),
    })
    setEngine({ engine, isInitialized: true })

    return () => {
      // cleanup
    }
  }, [setEngine])

  return (
    <div className="h-screen bg-background flex flex-col">
      <EditorToolbar />
      <div className="flex-1 flex overflow-hidden">
        <MediaPanel />
        <div className="flex-1 flex flex-col">
          <Preview />
          <Timeline />
        </div>
        <EffectsPanel />
      </div>
    </div>
  )
}
