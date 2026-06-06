'use client'

import { create } from 'zustand'
import { api, type AuthUser } from '@popcut/api-sdk'

interface AuthState {
  user: AuthUser | null
  isLoading: boolean
  error: string | null
  login: (email: string, password: string) => Promise<void>
  register: (email: string, password: string, name?: string) => Promise<void>
  logout: () => Promise<void>
  checkAuth: () => Promise<void>
}

export const useAuth = create<AuthState>((set) => ({
  user: null,
  isLoading: true,
  error: null,

  login: async (email, password) => {
    set({ isLoading: true, error: null })
    try {
      await api.authWithEmail(email, password)
      const user = await api.getMe()
      set({ user, isLoading: false })
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Login failed'
      set({ error: message, isLoading: false })
    }
  },

  register: async (email, password, name) => {
    set({ isLoading: true, error: null })
    try {
      await api.register(email, password, name)
      const user = await api.getMe()
      set({ user, isLoading: false })
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Registration failed'
      set({ error: message, isLoading: false })
    }
  },

  logout: async () => {
    await api.logout()
    set({ user: null })
  },

  checkAuth: async () => {
    if (!api.isAuthenticated()) {
      set({ isLoading: false })
      return
    }
    try {
      const user = await api.getMe()
      set({ user, isLoading: false })
    } catch {
      api.clearTokens()
      set({ isLoading: false })
    }
  },
}))
