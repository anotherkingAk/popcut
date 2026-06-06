'use client'

import Link from 'next/link'
import { AdminLayout } from '@/components/AdminLayout'
import { CreditCard, Ticket, DollarSign } from 'lucide-react'

export default function MonetizationPage() {
  const sections = [
    { href: '/monetization/plans', label: 'Plans', desc: 'Manage subscription plans and pricing', icon: CreditCard },
    { href: '/monetization/coupons', label: 'Coupons', desc: 'Create and manage discount coupons', icon: Ticket },
    { href: '/monetization/revenue', label: 'Revenue', desc: 'View revenue analytics and reports', icon: DollarSign },
  ]

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">Monetization</h1><p className="text-sm text-text-muted">Manage plans, coupons, and revenue</p></div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {sections.map(s => (
          <Link key={s.href} href={s.href} className="rounded-xl bg-surface border border-border p-6 hover:border-primary transition-colors group">
            <s.icon className="w-8 h-8 text-primary mb-3" />
            <h3 className="text-sm font-semibold text-text group-hover:text-primary transition-colors">{s.label}</h3>
            <p className="text-xs text-text-muted mt-1">{s.desc}</p>
          </Link>
        ))}
      </div>
    </AdminLayout>
  )
}
