'use client'

import { useEffect, useState } from 'react'
import { api, type CreditTxn } from '@/lib/api'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'
import { Plus } from 'lucide-react'

export default function CreditTxnsPage() {
  const [txns, setTxns] = useState<CreditTxn[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ userId: '', amount: 0, type: 'purchase', description: '' })

  const load = () => {
    const token = localStorage.getItem('admin_token')
    if (token) api.setToken(token)
    api.getCreditTxns().then(r => setTxns(r.data)).catch(console.error).finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    await api.createCreditTxn(form)
    setShowForm(false)
    setForm({ userId: '', amount: 0, type: 'purchase', description: '' })
    load()
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-text">Credit Transactions</h1><p className="text-sm text-text-muted">Track all credit movements</p></div>
        <button onClick={() => setShowForm(!showForm)} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-primary text-white text-sm hover:bg-primary-hover transition-colors"><Plus className="w-4 h-4" /> Add Credits</button>
      </div>

      {showForm && (
        <form onSubmit={handleCreate} className="mb-6 p-4 rounded-xl bg-surface border border-border space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <input placeholder="User ID" value={form.userId} onChange={e => setForm({...form, userId: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
            <input type="number" placeholder="Amount" value={form.amount || ''} onChange={e => setForm({...form, amount: parseInt(e.target.value) || 0})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
            <input placeholder="Type (purchase/refund/bonus)" value={form.type} onChange={e => setForm({...form, type: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
            <input placeholder="Description" value={form.description} onChange={e => setForm({...form, description: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
          </div>
          <button type="submit" className="px-3 py-1.5 rounded-lg bg-primary text-white text-sm">Add Credits</button>
        </form>
      )}

      <div className="rounded-xl bg-surface border border-border overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="border-b border-border text-text-muted text-xs uppercase">
            <th className="text-left px-4 py-3 font-medium">User</th><th className="text-left px-4 py-3 font-medium">Amount</th>
            <th className="text-left px-4 py-3 font-medium">Type</th><th className="text-left px-4 py-3 font-medium">Description</th>
            <th className="text-left px-4 py-3 font-medium">Date</th>
          </tr></thead>
          <tbody>
            {txns.map(t => (
              <tr key={t.id} className="border-b border-border last:border-0 hover:bg-surface-hover">
                <td className="px-4 py-3 text-text">{t.user?.name || t.user?.email || t.userId}</td>
                <td className="px-4 py-3"><span className={t.amount > 0 ? 'text-success' : 'text-danger'}>{t.amount > 0 ? '+' : ''}{t.amount}</span></td>
                <td className="px-4 py-3"><span className="px-2 py-0.5 rounded-full bg-surface-hover text-text-secondary text-xs">{t.type}</span></td>
                <td className="px-4 py-3 text-text-muted text-xs">{t.description || '-'}</td>
                <td className="px-4 py-3 text-text-muted text-xs">{formatDate(t.createdAt)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AdminLayout>
  )
}
