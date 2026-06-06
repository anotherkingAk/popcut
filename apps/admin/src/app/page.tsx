'use client'

import { useEffect, useState } from 'react'
import { api, type Dashboard } from '@/lib/api'
import { AdminLayout } from '@/components/AdminLayout'
import { Users, Video, Clapperboard, Sparkles, Cpu, DollarSign } from 'lucide-react'

export default function DashboardPage() {
  const [data, setData] = useState<Dashboard | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (token) api.setToken(token)
    api.getDashboard().then(setData).catch(console.error).finally(() => setLoading(false))
  }, [])

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  const cards = [
    { label: 'Users', value: data?.users ?? 0, icon: Users, color: 'text-primary' },
    { label: 'Projects', value: data?.projects ?? 0, icon: Video, color: 'text-accent' },
    { label: 'Templates', value: data?.templates ?? 0, icon: Clapperboard, color: 'text-success' },
    { label: 'Effects', value: data?.effects ?? 0, icon: Sparkles, color: 'text-warning' },
    { label: 'Active AI Jobs', value: data?.activeJobs ?? 0, icon: Cpu, color: 'text-danger' },
    { label: 'Revenue', value: `$${data?.revenue ?? 0}`, icon: DollarSign, color: 'text-success' },
  ]

  return (
    <AdminLayout>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-text">Dashboard</h1>
        <p className="text-sm text-text-muted">PopCut ecosystem overview</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
        {cards.map((card) => (
          <div key={card.label} className="rounded-xl bg-surface border border-border p-4">
            <div className="flex items-center justify-between mb-3">
              <span className="text-sm text-text-muted">{card.label}</span>
              <card.icon className={`w-5 h-5 ${card.color}`} />
            </div>
            <p className="text-3xl font-bold text-text">{card.value}</p>
          </div>
        ))}
      </div>

      <div className="rounded-xl bg-surface border border-border p-4">
        <h2 className="text-sm font-semibold text-text mb-4">Recent Users</h2>
        <div className="space-y-3">
          {data?.recentUsers.map((user) => (
            <div key={user.id} className="flex items-center justify-between py-2 border-b border-border last:border-0">
              <div>
                <p className="text-sm text-text">{user.name || user.email}</p>
                <p className="text-xs text-text-muted">{user.email}</p>
              </div>
              <span className="text-xs px-2 py-0.5 rounded-full bg-primary/10 text-primary capitalize">{user.role.toLowerCase()}</span>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  )
}
