'use client'

import { useEffect, useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'
import { Users, Activity, TrendingUp, Cpu, Download, HardDrive } from 'lucide-react'

const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

export default function AnalyticsPage() {
  const [data, setData] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (!token) return
    const fetchAll = async () => {
      try {
        const headers = { Authorization: `Bearer ${token}` }
        const [dau, mau, aiUsage, exportUsage] = await Promise.all([
          fetch(`${API}/api/v1/admin/analytics/dau`, { headers }).then(r => r.json()),
          fetch(`${API}/api/v1/admin/analytics/mau`, { headers }).then(r => r.json()),
          fetch(`${API}/api/v1/admin/analytics/ai-usage`, { headers }).then(r => r.json()),
          fetch(`${API}/api/v1/admin/analytics/export-usage`, { headers }).then(r => r.json()),
        ])
        setData({ dau, mau, aiUsage, exportUsage })
      } catch (e) { console.error(e) }
      finally { setLoading(false) }
    }
    fetchAll()
  }, [])

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  const metrics = [
    { label: 'DAU', value: data?.dau?.count ?? 0, icon: Users, color: 'text-primary' },
    { label: 'MAU', value: data?.mau?.count ?? 0, icon: Activity, color: 'text-accent' },
    { label: 'Retention', value: data?.mau?.retention ? `${Math.round(data.mau.retention)}%` : '0%', icon: TrendingUp, color: 'text-success' },
    { label: 'AI Usage', value: data?.aiUsage?.count ?? 0, icon: Cpu, color: 'text-warning' },
    { label: 'Exports', value: data?.exportUsage?.count ?? 0, icon: Download, color: 'text-danger' },
    { label: 'Storage', value: data?.exportUsage?.storage ? `${(data.exportUsage.storage / 1024 / 1024).toFixed(1)} GB` : '0 GB', icon: HardDrive, color: 'text-text-muted' },
  ]

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">Analytics</h1><p className="text-sm text-text-muted">Platform metrics and insights</p></div>
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-8">
        {metrics.map(m => (
          <div key={m.label} className="rounded-xl bg-surface border border-border p-4">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs text-text-muted">{m.label}</span>
              <m.icon className={`w-4 h-4 ${m.color}`} />
            </div>
            <p className="text-xl font-bold text-text">{m.value as string}</p>
          </div>
        ))}
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="rounded-xl bg-surface border border-border p-4">
          <h3 className="text-sm font-semibold text-text mb-3">Revenue Trend</h3>
          <div className="h-48 flex items-center justify-center bg-background rounded-lg border border-border"><p className="text-xs text-text-muted">Chart placeholder</p></div>
        </div>
        <div className="rounded-xl bg-surface border border-border p-4">
          <h3 className="text-sm font-semibold text-text mb-3">User Growth</h3>
          <div className="h-48 flex items-center justify-center bg-background rounded-lg border border-border"><p className="text-xs text-text-muted">Chart placeholder</p></div>
        </div>
        <div className="rounded-xl bg-surface border border-border p-4">
          <h3 className="text-sm font-semibold text-text mb-3">Popular Templates</h3>
          <div className="h-48 flex items-center justify-center bg-background rounded-lg border border-border"><p className="text-xs text-text-muted">Chart placeholder</p></div>
        </div>
        <div className="rounded-xl bg-surface border border-border p-4">
          <h3 className="text-sm font-semibold text-text mb-3">Popular Effects</h3>
          <div className="h-48 flex items-center justify-center bg-background rounded-lg border border-border"><p className="text-xs text-text-muted">Chart placeholder</p></div>
        </div>
      </div>
    </AdminLayout>
  )
}
