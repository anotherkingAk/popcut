'use client'

import { cn } from '@/lib/utils'

const statusStyles: Record<string, string> = {
  active: 'bg-success/10 text-success border-success/20',
  suspended: 'bg-danger/10 text-danger border-danger/20',
  published: 'bg-success/10 text-success border-success/20',
  draft: 'bg-warning/10 text-warning border-warning/20',
  archived: 'bg-text-muted/10 text-text-muted border-text-muted/20',
  completed: 'bg-success/10 text-success border-success/20',
  processing: 'bg-accent/10 text-accent border-accent/20',
  failed: 'bg-danger/10 text-danger border-danger/20',
  pending: 'bg-warning/10 text-warning border-warning/20',
  queued: 'bg-text-muted/10 text-text-muted border-text-muted/20',
  canceled: 'bg-text-muted/10 text-text-muted border-text-muted/20',
  expired: 'bg-danger/10 text-danger border-danger/20',
  trialing: 'bg-accent/10 text-accent border-accent/20',
}

interface StatusBadgeProps {
  status: string
  className?: string
}

export function StatusBadge({ status, className }: StatusBadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium',
        statusStyles[status] || 'bg-surface text-text-secondary border-border',
        className
      )}
    >
      {status}
    </span>
  )
}
