'use client'

import { cn } from '@/lib/utils'

interface ChartCardProps {
  title: string
  children: React.ReactNode
  className?: string
  action?: React.ReactNode
}

export function ChartCard({ title, children, className, action }: ChartCardProps) {
  return (
    <div className={cn('rounded-xl border border-border bg-surface p-5', className)}>
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-medium text-text">{title}</h3>
        {action}
      </div>
      {children}
    </div>
  )
}
