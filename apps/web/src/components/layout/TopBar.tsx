'use client'

import { Search, Bell } from 'lucide-react'
import { Avatar } from '../ui/avatar'

export function TopBar() {
  return (
    <header className="h-14 bg-surface border-b border-border flex items-center justify-between px-6">
      <div className="flex items-center gap-4 flex-1 max-w-md">
        <Search className="w-4 h-4 text-text-muted" />
        <input
          placeholder="Search projects, templates..."
          className="bg-transparent text-sm text-text placeholder:text-text-muted outline-none flex-1"
        />
      </div>

      <div className="flex items-center gap-4">
        <button className="relative p-2 rounded-lg hover:bg-surface-hover transition-colors">
          <Bell className="w-5 h-5 text-text-secondary" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-primary" />
        </button>
        <Avatar src="" alt="User" fallback="U" />
      </div>
    </header>
  )
}
