'use client'

import { useAdminUI } from '@/stores/admin-ui'
import { Menu, Bell, Search } from 'lucide-react'
import { Input } from '@/components/ui/input'

export function AdminHeader() {
  const { setMobileSidebarOpen } = useAdminUI()

  return (
    <header className="sticky top-0 z-20 flex h-14 items-center gap-4 border-b border-border bg-background px-4 lg:px-6">
      <button
        onClick={() => setMobileSidebarOpen(true)}
        className="lg:hidden text-text-muted hover:text-text"
      >
        <Menu className="h-5 w-5" />
      </button>
      <div className="relative flex-1 max-w-md hidden sm:block">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-text-muted" />
        <Input placeholder="Search..." className="pl-10 h-9" />
      </div>
      <div className="flex items-center gap-3 ml-auto">
        <button className="relative p-2 rounded-lg text-text-muted hover:text-text hover:bg-surface-hover transition-colors">
          <Bell className="h-5 w-5" />
          <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-danger" />
        </button>
        <div className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/20 text-primary text-xs font-bold">
            A
          </div>
          <span className="text-sm text-text hidden sm:block">Admin</span>
        </div>
      </div>
    </header>
  )
}
