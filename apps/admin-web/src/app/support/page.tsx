'use client'

import { useEffect, useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'
import { MessageSquare, CheckCircle, UserPlus } from 'lucide-react'

interface Ticket { id: string; userId: string; user?: { email: string; name?: string }; subject: string; message: string; status: string; priority: string; category: string; assignedTo?: string; createdAt: string }

const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

export default function SupportPage() {
  const [tickets, setTickets] = useState<Ticket[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState('open')

  const load = async () => {
    const token = localStorage.getItem('admin_token')
    try {
      const res = await fetch(`${API}/api/v1/admin/support?status=${filter}&page=1&limit=50`, { headers: { Authorization: `Bearer ${token}` } })
      const data = await res.json()
      setTickets(data.data || [])
    } catch (e) { console.error(e) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [filter])

  const resolveTicket = async (id: string) => {
    const token = localStorage.getItem('admin_token')
    await fetch(`${API}/api/v1/admin/support/${id}/resolve`, { method: 'PUT', headers: { Authorization: `Bearer ${token}` } })
    setTickets(prev => prev.filter(t => t.id !== id))
  }

  const assignTicket = async (id: string) => {
    const name = prompt('Assign to (admin email):')
    if (!name) return
    const token = localStorage.getItem('admin_token')
    await fetch(`${API}/api/v1/admin/support/${id}/assign`, {
      method: 'PUT', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify({ assignedTo: name }),
    })
    load()
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-text">Support</h1><p className="text-sm text-text-muted">Manage support tickets</p></div>
        <div className="flex gap-1 bg-surface rounded-lg border border-border p-0.5">
          {['open', 'in_progress', 'resolved'].map(s => (
            <button key={s} onClick={() => setFilter(s)} className={`px-3 py-1.5 rounded text-xs transition-colors ${filter === s ? 'bg-primary text-white' : 'text-text-secondary hover:text-text'}`}>{s.replace('_', ' ')}</button>
          ))}
        </div>
      </div>
      <div className="space-y-2">
        {tickets.map(ticket => (
          <div key={ticket.id} className="rounded-xl bg-surface border border-border p-4">
            <div className="flex items-start justify-between mb-2">
              <div>
                <h3 className="text-sm font-medium text-text">{ticket.subject}</h3>
                <p className="text-xs text-text-muted">{ticket.user?.name || ticket.user?.email || ticket.userId}</p>
              </div>
              <div className="flex items-center gap-2">
                <span className={`px-2 py-0.5 rounded-full text-xs ${ticket.priority === 'high' ? 'bg-danger/10 text-danger' : ticket.priority === 'medium' ? 'bg-warning/10 text-warning' : 'bg-surface-hover text-text-secondary'}`}>{ticket.priority}</span>
                <span className="px-2 py-0.5 rounded-full bg-surface-hover text-text-secondary text-xs">{ticket.category}</span>
              </div>
            </div>
            <p className="text-xs text-text-secondary mb-3 line-clamp-2">{ticket.message}</p>
            <div className="flex items-center justify-between">
              <p className="text-[10px] text-text-muted">{formatDate(ticket.createdAt)}{ticket.assignedTo ? ` · Assigned to ${ticket.assignedTo}` : ''}</p>
              <div className="flex gap-1">
                <button onClick={() => assignTicket(ticket.id)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-primary" title="Assign"><UserPlus className="w-3.5 h-3.5" /></button>
                <button onClick={() => resolveTicket(ticket.id)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-success" title="Resolve"><CheckCircle className="w-3.5 h-3.5" /></button>
              </div>
            </div>
          </div>
        ))}
        {tickets.length === 0 && <p className="text-sm text-text-muted text-center py-8">No {filter} tickets</p>}
      </div>
    </AdminLayout>
  )
}
