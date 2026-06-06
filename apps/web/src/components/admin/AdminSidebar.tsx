'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'
import { useAdminUI } from '@/stores/admin-ui'
import {
  LayoutDashboard, Users, FolderKanban, Film, Sparkles, SlidersHorizontal,
  Palette, Type, Music, ArrowRightLeft, Droplets, Cpu, CreditCard,
  Coins, BarChart3, History, Settings, ChevronLeft, ChevronRight, X,
} from 'lucide-react'
import { useEffect } from 'react'

const navItems = [
  { section: 'Overview', items: [
    { href: '/admin/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  ]},
  { section: 'Management', items: [
    { href: '/admin/users', label: 'Users', icon: Users },
    { href: '/admin/projects', label: 'Projects', icon: FolderKanban },
  ]},
  { section: 'Content', items: [
    { href: '/admin/content/templates', label: 'Templates', icon: Film },
    { href: '/admin/content/effects', label: 'Effects', icon: Sparkles },
    { href: '/admin/content/filters', label: 'Filters', icon: SlidersHorizontal },
    { href: '/admin/content/color-grades', label: 'Color Grades', icon: Palette },
    { href: '/admin/content/fonts', label: 'Fonts', icon: Type },
    { href: '/admin/content/audio', label: 'Audio', icon: Music },
    { href: '/admin/content/transitions', label: 'Transitions', icon: ArrowRightLeft },
  ]},
  { section: 'AI', items: [
    { href: '/admin/ai-factory', label: 'AI Factory', icon: Cpu },
  ]},
  { section: 'Revenue', items: [
    { href: '/admin/subscriptions', label: 'Subscriptions', icon: CreditCard },
    { href: '/admin/credits', label: 'Credits', icon: Coins },
  ]},
  { section: 'Insights', items: [
    { href: '/admin/analytics', label: 'Analytics', icon: BarChart3 },
    { href: '/admin/audit-logs', label: 'Audit Logs', icon: History },
  ]},
  { section: 'System', items: [
    { href: '/admin/settings', label: 'Settings', icon: Settings },
  ]},
]

export function AdminSidebar() {
  const pathname = usePathname()
  const { sidebarOpen, mobileSidebarOpen, toggleSidebar, setMobileSidebarOpen } = useAdminUI()

  useEffect(() => {
    setMobileSidebarOpen(false)
  }, [pathname, setMobileSidebarOpen])

  const sidebarContent = (
    <div className="flex h-full flex-col">
      <div className="flex h-14 items-center justify-between px-4 border-b border-border">
        <Link href="/admin/dashboard" className="flex items-center gap-2">
          <div className="flex h-7 w-7 items-center justify-center rounded-md bg-primary">
            <span className="text-xs font-bold text-white">P</span>
          </div>
          {sidebarOpen && <span className="font-semibold text-sm text-text">PopCut Admin</span>}
        </Link>
        <button
          onClick={toggleSidebar}
          className="hidden lg:flex h-6 w-6 items-center justify-center rounded-md text-text-muted hover:text-text hover:bg-surface-hover"
        >
          {sidebarOpen ? <ChevronLeft className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
        </button>
      </div>
      <nav className="flex-1 overflow-y-auto scrollbar-thin px-2 py-4 space-y-6">
        {navItems.map((section) => (
          <div key={section.section}>
            {sidebarOpen && (
              <p className="px-2 mb-2 text-xs font-semibold uppercase tracking-wider text-text-muted">
                {section.section}
              </p>
            )}
            <div className="space-y-0.5">
              {section.items.map((item) => {
                const isActive = pathname === item.href || pathname.startsWith(item.href + '/')
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={cn(
                      'flex items-center gap-3 rounded-lg px-2 py-2 text-sm transition-colors',
                      isActive
                        ? 'bg-primary/10 text-primary font-medium'
                        : 'text-text-secondary hover:text-text hover:bg-surface-hover'
                    )}
                  >
                    <item.icon className="h-4 w-4 shrink-0" />
                    {sidebarOpen && <span>{item.label}</span>}
                  </Link>
                )
              })}
            </div>
          </div>
        ))}
      </nav>
    </div>
  )

  return (
    <>
      {/* Desktop sidebar */}
      <aside
        className={cn(
          'fixed left-0 top-0 z-30 hidden lg:block h-full border-r border-border bg-background transition-all duration-200',
          sidebarOpen ? 'w-56' : 'w-16'
        )}
      >
        {sidebarContent}
      </aside>
      {/* Mobile overlay */}
      {mobileSidebarOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <div className="absolute inset-0 bg-black/60" onClick={() => setMobileSidebarOpen(false)} />
          <aside className="relative w-64 h-full bg-background border-r border-border">
            <div className="flex h-14 items-center justify-between px-4 border-b border-border">
              <Link href="/admin/dashboard" className="flex items-center gap-2">
                <div className="flex h-7 w-7 items-center justify-center rounded-md bg-primary">
                  <span className="text-xs font-bold text-white">P</span>
                </div>
                <span className="font-semibold text-sm text-text">PopCut Admin</span>
              </Link>
              <button onClick={() => setMobileSidebarOpen(false)} className="text-text-muted hover:text-text">
                <X className="h-5 w-5" />
              </button>
            </div>
            {sidebarContent}
          </aside>
        </div>
      )}
    </>
  )
}
