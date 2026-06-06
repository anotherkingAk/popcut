'use client'

import { useEffect, useState } from 'react'
import { api, type Subscription } from '@/lib/api'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'

export default function SubscriptionsPage() {
  const [subs, setSubs] = useState<Subscription[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (token) api.setToken(token)
    api.getSubscriptions().then(r => setSubs(r.data)).catch(console.error).finally(() => setLoading(false))
  }, [])

  const toggleStatus = async (sub: Subscription) => {
    const newStatus = sub.status === 'active' ? 'cancelled' : 'active'
    await api.updateSubscription(sub.id, { status: newStatus })
    setSubs(prev => prev.map(s => s.id === sub.id ? { ...s, status: newStatus } : s))
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">Subscriptions</h1><p className="text-sm text-text-muted">Manage user subscriptions and plans</p></div>
      <div className="rounded-xl bg-surface border border-border overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="border-b border-border text-text-muted text-xs uppercase">
            <th className="text-left px-4 py-3 font-medium">User</th><th className="text-left px-4 py-3 font-medium">Plan</th>
            <th className="text-left px-4 py-3 font-medium">Price</th><th className="text-left px-4 py-3 font-medium">Status</th>
            <th className="text-left px-4 py-3 font-medium">Start</th><th className="text-left px-4 py-3 font-medium">End</th>
            <th className="text-right px-4 py-3 font-medium">Actions</th>
          </tr></thead>
          <tbody>
            {subs.map(sub => (
              <tr key={sub.id} className="border-b border-border last:border-0 hover:bg-surface-hover">
                <td className="px-4 py-3 text-text">{sub.user?.name || sub.user?.email || sub.userId}</td>
                <td className="px-4 py-3"><span className="px-2 py-0.5 rounded-full bg-primary/10 text-primary text-xs capitalize">{sub.plan}</span></td>
                <td className="px-4 py-3 text-text">${sub.price}/mo</td>
                <td className="px-4 py-3">{sub.status === 'active' ? <span className="text-success text-xs">Active</span> : <span className="text-danger text-xs">{sub.status}</span>}</td>
                <td className="px-4 py-3 text-text-muted text-xs">{formatDate(sub.startDate)}</td>
                <td className="px-4 py-3 text-text-muted text-xs">{sub.endDate ? formatDate(sub.endDate) : '-'}</td>
                <td className="px-4 py-3 text-right">
                  <button onClick={() => toggleStatus(sub)} className="px-2 py-1 rounded text-xs bg-surface-hover text-text-secondary hover:text-text">{sub.status === 'active' ? 'Cancel' : 'Activate'}</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AdminLayout>
  )
}
