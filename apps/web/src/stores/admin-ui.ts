import { create } from 'zustand'

interface AdminUIState {
  sidebarOpen: boolean
  mobileSidebarOpen: boolean
  toggleSidebar: () => void
  setMobileSidebarOpen: (open: boolean) => void
  setSidebarOpen: (open: boolean) => void
}

export const useAdminUI = create<AdminUIState>((set) => ({
  sidebarOpen: true,
  mobileSidebarOpen: false,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  setMobileSidebarOpen: (open) => set({ mobileSidebarOpen: open }),
  setSidebarOpen: (open) => set({ sidebarOpen: open }),
}))
