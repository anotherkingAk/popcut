'use client'

import { useEffect, useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'
import { Plus, Trash2 } from 'lucide-react'

interface Coupon { id: string; code: string; description?: string; discountType: string; discountValue: number; maxUses?: number; usedCount: number; minAmount: number; expiresAt?: string; isActive: boolean; createdAt: string }

const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

async function apiGet<T>(path: string): Promise<T> {
  const token = localStorage.getItem('admin_token')
  const res = await fetch(`${API}/api/v1${path}`, { headers: { Authorization: `Bearer ${token}` } })
  return res.json()
}

async function apiMutate(method: string, path: string, body?: any) {
  const token = localStorage.getItem('admin_token')
  const res = await fetch(`${API}/api/v1${path}`, {
    method, headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: body ? JSON.stringify(body) : undefined,
  })
  return res.json()
}

export default function CouponsPage() {
  const [coupons, setCoupons] = useState<Coupon[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ code: '', description: '', discountType: 'percentage', discountValue: 10, maxUses: 100, minAmount: 0 })

  const load = async () => {
    try { const data = await apiGet<{ data: Coupon[] }>('/admin/coupons?page=1&limit=50'); setCoupons(data.data) }
    catch (e) { console.error(e) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [])

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    await apiMutate('POST', '/admin/coupons', form)
    setShowForm(false)
    setForm({ code: '', description: '', discountType: 'percentage', discountValue: 10, maxUses: 100, minAmount: 0 })
    load()
  }

  const toggleActive = async (coupon: Coupon) => {
    await apiMutate('PUT', `/admin/coupons/${coupon.id}`, { isActive: !coupon.isActive })
    setCoupons(prev => prev.map(c => c.id === coupon.id ? { ...c, isActive: !c.isActive } : c))
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this coupon?')) return
    await apiMutate('DELETE', `/admin/coupons/${id}`)
    setCoupons(prev => prev.filter(c => c.id !== id))
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-text">Coupons</h1><p className="text-sm text-text-muted">Create and manage discount coupons</p></div>
        <button onClick={() => setShowForm(!showForm)} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-primary text-white text-sm hover:bg-primary-hover"><Plus className="w-4 h-4" /> Add Coupon</button>
      </div>
      {showForm && (
        <form onSubmit={handleCreate} className="mb-6 p-4 rounded-xl bg-surface border border-border space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <input placeholder="Coupon Code" value={form.code} onChange={e => setForm({...form, code: e.target.value.toUpperCase()})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary font-mono uppercase" required />
            <input placeholder="Description" value={form.description} onChange={e => setForm({...form, description: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
            <select value={form.discountType} onChange={e => setForm({...form, discountType: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary">
              <option value="percentage">Percentage</option><option value="fixed">Fixed Amount</option>
            </select>
            <input type="number" placeholder="Discount Value" value={form.discountValue} onChange={e => setForm({...form, discountValue: parseInt(e.target.value) || 0})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
            <input type="number" placeholder="Max Uses" value={form.maxUses || ''} onChange={e => setForm({...form, maxUses: parseInt(e.target.value) || undefined})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
            <input type="number" placeholder="Min Amount (cents)" value={form.minAmount || ''} onChange={e => setForm({...form, minAmount: parseInt(e.target.value) || 0})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
          </div>
          <button type="submit" className="px-3 py-1.5 rounded-lg bg-primary text-white text-sm">Create</button>
        </form>
      )}
      <div className="rounded-xl bg-surface border border-border overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="border-b border-border text-text-muted text-xs uppercase">
            <th className="text-left px-4 py-3 font-medium">Code</th><th className="text-left px-4 py-3 font-medium">Discount</th>
            <th className="text-left px-4 py-3 font-medium">Uses</th><th className="text-left px-4 py-3 font-medium">Status</th>
            <th className="text-left px-4 py-3 font-medium">Created</th><th className="text-right px-4 py-3 font-medium">Actions</th>
          </tr></thead>
          <tbody>
            {coupons.map(c => (
              <tr key={c.id} className="border-b border-border last:border-0 hover:bg-surface-hover">
                <td className="px-4 py-3"><span className="font-mono text-sm font-bold text-primary">{c.code}</span></td>
                <td className="px-4 py-3 text-text">{c.discountType === 'percentage' ? `${c.discountValue}%` : `$${(c.discountValue / 100).toFixed(2)}`}</td>
                <td className="px-4 py-3 text-text-muted">{c.usedCount}{c.maxUses ? ` / ${c.maxUses}` : ''}</td>
                <td className="px-4 py-3">
                  <button onClick={() => toggleActive(c)} className={`px-2 py-0.5 rounded-full text-xs ${c.isActive ? 'bg-success/10 text-success' : 'bg-danger/10 text-danger'}`}>
                    {c.isActive ? 'Active' : 'Disabled'}
                  </button>
                </td>
                <td className="px-4 py-3 text-text-muted text-xs">{formatDate(c.createdAt)}</td>
                <td className="px-4 py-3 text-right"><button onClick={() => handleDelete(c.id)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-danger"><Trash2 className="w-4 h-4" /></button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AdminLayout>
  )
}
