'use client'

export function AdminTopBar() {
  return (
    <header className="h-14 bg-surface border-b border-border flex items-center justify-between px-6">
      <div />
      <div className="flex items-center gap-3 text-xs text-text-muted">
        <span className="w-2 h-2 rounded-full bg-success animate-pulse" />
        System Online
      </div>
    </header>
  )
}
