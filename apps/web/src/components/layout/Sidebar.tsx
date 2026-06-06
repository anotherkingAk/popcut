'use client'

import React from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'
import {
  LayoutDashboard,
  Video,
  Clapperboard,
  Sparkles,
  Settings,
  LogOut,
} from 'lucide-react'

const navItems = [
  { href: '/projects', label: 'Projects', icon: LayoutDashboard },
  { href: '/editor', label: 'Editor', icon: Video },
  { href: '/templates', label: 'Templates', icon: Clapperboard },
  { href: '/ai-studio', label: 'AI Studio', icon: Sparkles },
]

const NavItem = React.memo(({ href, icon: Icon, label, isActive }: {
  href: string
  icon: React.ComponentType<{ className?: string }>
  label: string
  isActive: boolean
}) => (
  <Link
    href={href}
    className={cn(
      'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors',
      isActive
        ? 'bg-primary/10 text-primary'
        : 'text-text-secondary hover:bg-surface-hover hover:text-text'
    )}
  >
    <Icon className="w-5 h-5 shrink-0" />
    <span className="hidden lg:block">{label}</span>
  </Link>
))

export function Sidebar() {
  const pathname = usePathname()

  return (
    <aside className="w-16 lg:w-56 h-screen bg-surface border-r border-border flex flex-col fixed left-0 top-0 z-30">
      <div className="h-14 flex items-center px-4 border-b border-border">
        <Link href="/projects" className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
            <Video className="w-4 h-4 text-white" />
          </div>
          <span className="hidden lg:block font-bold text-text">PopCut</span>
        </Link>
      </div>

      <nav className="flex-1 py-4 px-2 space-y-1">
        {navItems.map((item) => (
          <NavItem
            key={item.href}
            href={item.href}
            icon={item.icon}
            label={item.label}
            isActive={pathname.startsWith(item.href)}
          />
        ))}
      </nav>

      <div className="p-2 border-t border-border space-y-1">
        <Link
          href="/settings"
          className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-text-secondary hover:bg-surface-hover hover:text-text transition-colors"
        >
          <Settings className="w-5 h-5 shrink-0" />
          <span className="hidden lg:block">Settings</span>
        </Link>
        <button
          className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-text-secondary hover:bg-surface-hover hover:text-danger transition-colors w-full"
        >
          <LogOut className="w-5 h-5 shrink-0" />
          <span className="hidden lg:block">Logout</span>
        </button>
      </div>
    </aside>
  )
}
