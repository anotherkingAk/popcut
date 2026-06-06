'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { cn } from '@/lib/utils'
import {
  LayoutDashboard, Users, Video, Clapperboard, Sparkles,
  Palette, Type, Music, CreditCard, Cpu, Download,
  Flag, Shield, DollarSign, LogOut, ChevronLeft,
} from 'lucide-react'
import { useState } from 'react'

const navSections = [
  { label: 'Management', items: [
    { href: '/', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/users', label: 'Users', icon: Users },
    { href: '/projects', label: 'Projects', icon: Video },
  ]},
  { label: 'Content', items: [
    { href: '/templates', label: 'Templates', icon: Clapperboard },
    { href: '/effects', label: 'Effects', icon: Sparkles },
    { href: '/filters', label: 'Filters', icon: Palette },
    { href: '/fonts', label: 'Fonts', icon: Type },
    { href: '/audio', label: 'Audio', icon: Music },
  ]},
  { label: 'Operations', items: [
    { href: '/subscriptions', label: 'Subscriptions', icon: CreditCard },
    { href: '/credit-transactions', label: 'Credits', icon: DollarSign },
    { href: '/ai-jobs', label: 'AI Jobs', icon: Cpu },
    { href: '/export-jobs', label: 'Exports', icon: Download },
  ]},
  { label: 'System', items: [
    { href: '/feature-flags', label: 'Feature Flags', icon: Flag },
    { href: '/audit-logs', label: 'Audit Logs', icon: Shield },
  ]},
]

export function AdminSidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const [collapsed, setCollapsed] = useState(false)

  const handleLogout = () => {
    localStorage.removeItem('admin_token')
    router.push('/login')
  }

  return (
    <aside className={cn(
      'h-screen bg-surface border-r border-border flex flex-col fixed left-0 top-0 z-30 transition-all duration-200',
      collapsed ? 'w-16' : 'w-60'
    )}>
      <div className="h-14 flex items-center justify-between px-4 border-b border-border">
        <Link href="/" className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center shrink-0">
            <LayoutDashboard className="w-4 h-4 text-white" />
          </div>
          {!collapsed && <span className="font-bold text-sm text-text">PopCut Admin</span>}
        </Link>
        <button onClick={() => setCollapsed(!collapsed)} className="p-1 rounded hover:bg-surface-hover text-text-muted">
          <ChevronLeft className={cn('w-4 h-4 transition-transform', collapsed && 'rotate-180')} />
        </button>
      </div>

      <nav className="flex-1 py-4 overflow-y-auto scrollbar-thin">
        {navSections.map((section) => (
          <div key={section.label} className="mb-4">
            {!collapsed && (
              <p className="px-4 mb-1 text-[10px] font-semibold uppercase tracking-wider text-text-muted">{section.label}</p>
            )}
            {section.items.map((item) => {
              const isActive = pathname === item.href || (item.href !== '/' && pathname.startsWith(item.href))
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    'flex items-center gap-3 mx-2 px-3 py-2 rounded-lg text-sm transition-colors',
                    isActive ? 'bg-primary/10 text-primary' : 'text-text-secondary hover:bg-surface-hover hover:text-text'
                  )}
                  title={collapsed ? item.label : undefined}
                >
                  <item.icon className="w-4 h-4 shrink-0" />
                  {!collapsed && <span className="truncate">{item.label}</span>}
                </Link>
              )
            })}
          </div>
        ))}
      </nav>

      <div className="p-2 border-t border-border">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 w-full px-3 py-2 rounded-lg text-sm text-text-secondary hover:bg-surface-hover hover:text-danger transition-colors"
        >
          <LogOut className="w-4 h-4 shrink-0" />
          {!collapsed && <span>Logout</span>}
        </button>
      </div>
    </aside>
  )
}
