'use client'

import { useEffect, useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'
import { Bell, CheckCheck, Send } from 'lucide-react'

interface Notification { id: string; userId: string; type: string; title: string; message: string; read: boolean; link?: string; createdAt: string }

const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [loading, setLoading] = useState(true)
  const [showBroadcast, setShowBroadcast] = useState(false)
  const [broadcast, setBroadcast] = useState({ title: '', message: '', type: 'info' })

  const load = async () => {
    const token = localStorage.getItem('admin_token')
    try {
      const res = await fetch(`${API}/api/v1/admin/notifications?page=1&limit=50`, { headers: { Authorization: `Bearer ${token}` } })
      const data = await res.json()
      setNotifications(data.data || [])
    } catch (e) { console.error(e) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [])

  const markRead = async (id: string) => {
    const token = localStorage.getItem('admin_token')
    await fetch(`${API}/api/v1/admin/notifications/${id}/read`, { method: 'PUT', headers: { Authorization: `Bearer ${token}` } })
    setNotifications(prev => prev.map(n => n.id === id ? { ...n, read: true } : n))
  }

  const markAllRead = async () => {
    const token = localStorage.getItem('admin_token')
    await fetch(`${API}/api/v1/admin/notifications/read-all`, { method: 'PUT', headers: { Authorization: `Bearer ${token}` } })
    setNotifications(prev => prev.map(n => ({ ...n, read: true })))
  }

  const handleBroadcast = async (e: React.FormEvent) => {
    e.preventDefault()
    const token = localStorage.getItem('admin_token')
    await fetch(`${API}/api/v1/admin/notifications/broadcast`, {
      method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify(broadcast),
    })
    setShowBroadcast(false)
    setBroadcast({ title: '', message: '', type: 'info' })
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-text">Notifications</h1><p className="text-sm text-text-muted">Manage system notifications</p></div>
        <div className="flex gap-2">
          <button onClick={markAllRead} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-surface-hover text-text-secondary text-sm hover:text-text transition-colors"><CheckCheck className="w-4 h-4" /> Mark All Read</button>
          <button onClick={() => setShowBroadcast(!showBroadcast)} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-primary text-white text-sm hover:bg-primary-hover"><Send className="w-4 h-4" /> Broadcast</button>
        </div>
      </div>

      {showBroadcast && (
        <form onSubmit={handleBroadcast} className="mb-6 p-4 rounded-xl bg-surface border border-border space-y-3">
          <input placeholder="Title" value={broadcast.title} onChange={e => setBroadcast({...broadcast, title: e.target.value})} className="w-full h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
          <textarea placeholder="Message" value={broadcast.message} onChange={e => setBroadcast({...broadcast, message: e.target.value})} className="w-full h-24 rounded-lg bg-background border border-border px-3 py-2 text-sm text-text outline-none focus:border-primary" required />
          <div className="flex items-center gap-4">
            <select value={broadcast.type} onChange={e => setBroadcast({...broadcast, type: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary">
              <option value="info">Info</option><option value="warning">Warning</option><option value="success">Success</option><option value="error">Error</option>
            </select>
            <button type="submit" className="px-3 py-1.5 rounded-lg bg-primary text-white text-sm">Send to All Users</button>
          </div>
        </form>
      )}

      <div className="space-y-2">
        {notifications.map(n => (
          <div key={n.id} className={`flex items-start gap-3 p-4 rounded-xl border transition-colors cursor-pointer ${n.read ? 'bg-surface border-border' : 'bg-surface border-primary/30'}`} onClick={() => !n.read && markRead(n.id)}>
            <div className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${n.read ? 'bg-surface-hover' : 'bg-primary/20'}`}>
              <Bell className={`w-4 h-4 ${n.read ? 'text-text-muted' : 'text-primary'}`} />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <p className={`text-sm ${n.read ? 'text-text-secondary' : 'text-text font-medium'}`}>{n.title}</p>
                {!n.read && <div className="w-2 h-2 rounded-full bg-primary shrink-0" />}
              </div>
              <p className="text-xs text-text-muted mt-0.5">{n.message}</p>
              <p className="text-[10px] text-text-muted mt-1">{formatDate(n.createdAt)}</p>
            </div>
          </div>
        ))}
        {notifications.length === 0 && <p className="text-sm text-text-muted text-center py-8">No notifications</p>}
      </div>
    </AdminLayout>
  )
}
