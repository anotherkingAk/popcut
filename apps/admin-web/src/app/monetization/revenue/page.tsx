'use client'

import { useEffect, useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'

const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

export default function RevenuePage() {
  const [revenue, setRevenue] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (!token) return
    fetch(`${API}/api/v1/admin/analytics/revenue`, { headers: { Authorization: `Bearer ${token}` } })
      .then(r => r.json())
      .then(setRevenue)
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">Revenue</h1><p className="text-sm text-text-muted">Revenue analytics and reports</p></div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="rounded-xl bg-surface border border-border p-4">
          <p className="text-xs text-text-muted mb-1">Total Revenue</p>
          <p className="text-2xl font-bold text-text">${revenue?.total ? (revenue.total / 100).toFixed(2) : '0.00'}</p>
        </div>
        <div className="rounded-xl bg-surface border border-border p-4">
          <p className="text-xs text-text-muted mb-1">This Month</p>
          <p className="text-2xl font-bold text-text">${revenue?.monthly ? (revenue.monthly / 100).toFixed(2) : '0.00'}</p>
        </div>
        <div className="rounded-xl bg-surface border border-border p-4">
          <p className="text-xs text-text-muted mb-1">MRR</p>
          <p className="text-2xl font-bold text-text">${revenue?.mrr ? (revenue.mrr / 100).toFixed(2) : '0.00'}</p>
        </div>
      </div>
      <div className="rounded-xl bg-surface border border-border p-6">
        <h2 className="text-sm font-semibold text-text mb-4">Revenue Chart</h2>
        <div className="h-64 flex items-center justify-center bg-background rounded-lg border border-border">
          <p className="text-sm text-text-muted">Revenue chart will render here with recharts</p>
        </div>
      </div>
    </AdminLayout>
  )
}
