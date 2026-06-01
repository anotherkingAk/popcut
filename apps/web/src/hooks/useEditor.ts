'use client'

import { useEffect, useRef, useCallback } from 'react'
import { create } from 'zustand'
import { TimelineEngine } from '@capcard/editor-engine'

interface EditorState {
  engine: TimelineEngine | null
  isInitialized: boolean
  currentTime: number
  isPlaying: boolean
  zoom: number
}

const useEditorStore = create<EditorState>(() => ({
  engine: null,
  isInitialized: false,
  currentTime: 0,
  isPlaying: false,
  zoom: 1,
}))

export function useEditor() {
  const store = useEditorStore()
  const engineRef = useRef<TimelineEngine | null>(null)

  useEffect(() => {
    const engine = new TimelineEngine()
    engineRef.current = engine

    const timeSub = engine.onTime().subscribe(time => {
      useEditorStore.setState({ currentTime: time })
    })
    const playSub = engine.onPlayState().subscribe(isPlaying => {
      useEditorStore.setState({ isPlaying })
    })
    const projSub = engine.onProject().subscribe(() => {
      useEditorStore.setState({ isInitialized: true })
    })

    return () => {
      timeSub.unsubscribe()
      playSub.unsubscribe()
      projSub.unsubscribe()
    }
  }, [])

  const seek = useCallback((time: number) => {
    engineRef.current?.seek(time)
  }, [])

  const play = useCallback(() => {
    engineRef.current?.play()
  }, [])

  const pause = useCallback(() => {
    engineRef.current?.pause()
  }, [])

  const togglePlay = useCallback(() => {
    engineRef.current?.togglePlay()
  }, [])

  const zoomIn = useCallback(() => {
    useEditorStore.setState(s => ({ zoom: Math.min(s.zoom * 1.2, 10) }))
  }, [])

  const zoomOut = useCallback(() => {
    useEditorStore.setState(s => ({ zoom: Math.max(s.zoom / 1.2, 0.1) }))
  }, [])

  return {
    engine: engineRef.current,
    currentTime: store.currentTime,
    isPlaying: store.isPlaying,
    zoom: store.zoom,
    seek,
    play,
    pause,
    togglePlay,
    zoomIn,
    zoomOut,
  }
}

export { useEditorStore }
