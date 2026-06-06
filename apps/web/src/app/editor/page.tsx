'use client'

import { useEffect, Suspense, lazy } from 'react'
import dynamic from 'next/dynamic'
import { TimelineEngine } from '@popcut/editor-engine'
import { useEditorStore } from '@/hooks/useEditor'

const EditorToolbar = dynamic(() => import('@/components/editor/EditorToolbar').then(m => ({ default: m.EditorToolbar })), {
  ssr: false,
})
const Timeline = dynamic(() => import('@/components/editor/Timeline').then(m => ({ default: m.Timeline })), {
  ssr: false,
})
const Preview = dynamic(() => import('@/components/editor/Preview').then(m => ({ default: m.Preview })), {
  ssr: false,
})
const MediaPanel = dynamic(() => import('@/components/editor/MediaPanel').then(m => ({ default: m.MediaPanel })), {
  ssr: false,
})
const EffectsPanel = dynamic(() => import('@/components/editor/EffectsPanel').then(m => ({ default: m.EffectsPanel })), {
  ssr: false,
})

function LoadingFallback() {
  return <div className="flex items-center justify-center h-full bg-surface"><div className="w-6 h-6 rounded-full border-2 border-primary border-t-transparent animate-spin" /></div>
}

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
      engine.destroy()
    }
  }, [setEngine])

  return (
    <div className="h-screen bg-background flex flex-col">
      <Suspense fallback={<LoadingFallback />}>
        <EditorToolbar />
      </Suspense>
      <div className="flex-1 flex overflow-hidden">
        <Suspense fallback={<LoadingFallback />}>
          <MediaPanel />
        </Suspense>
        <div className="flex-1 flex flex-col">
          <Suspense fallback={<LoadingFallback />}>
            <Preview />
          </Suspense>
          <Suspense fallback={<LoadingFallback />}>
            <Timeline />
          </Suspense>
        </div>
        <Suspense fallback={<LoadingFallback />}>
          <EffectsPanel />
        </Suspense>
      </div>
    </div>
  )
}
