'use client'

import { useEffect, useRef, useCallback } from 'react'
import { create } from 'zustand'
import { TimelineEngine } from '@popcut/editor-engine'

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

// Granular selector hooks - components only re-render when their specific value changes
export function useEngine() {
  return useEditorStore(s => s.engine)
}
export function useIsInitialized() {
  return useEditorStore(s => s.isInitialized)
}
export function useCurrentTime() {
  return useEditorStore(s => s.currentTime)
}
export function useIsPlaying() {
  return useEditorStore(s => s.isPlaying)
}
export function useZoom() {
  return useEditorStore(s => s.zoom)
}

export function useEditorActions() {
  const engineRef = useRef<TimelineEngine | null>(null)
  const engine = useEditorStore(s => s.engine)

  useEffect(() => {
    engineRef.current = engine
  }, [engine])

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

  return { seek, play, pause, togglePlay, zoomIn, zoomOut }
}

// Legacy hook - kept for backward compatibility but prefer granular hooks
export function useEditor() {
  const currentTime = useEditorStore(s => s.currentTime)
  const isPlaying = useEditorStore(s => s.isPlaying)
  const zoom = useEditorStore(s => s.zoom)
  const engine = useEditorStore(s => s.engine)

  const engineRef = useRef<TimelineEngine | null>(null)
  useEffect(() => { engineRef.current = engine }, [engine])

  const seek = useCallback((time: number) => { engineRef.current?.seek(time) }, [])
  const play = useCallback(() => { engineRef.current?.play() }, [])
  const pause = useCallback(() => { engineRef.current?.pause() }, [])
  const togglePlay = useCallback(() => { engineRef.current?.togglePlay() }, [])
  const zoomIn = useCallback(() => { useEditorStore.setState(s => ({ zoom: Math.min(s.zoom * 1.2, 10) })) }, [])
  const zoomOut = useCallback(() => { useEditorStore.setState(s => ({ zoom: Math.max(s.zoom / 1.2, 0.1) })) }, [])

  return { engine, currentTime, isPlaying, zoom, seek, play, pause, togglePlay, zoomIn, zoomOut }
}

export { useEditorStore }
