'use client'

import { useEffect, useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'
import { Plus, Trash2, CheckCircle } from 'lucide-react'

interface Plan { id: string; name: string; description?: string; price: number; interval: string; credits: number; features: any; isActive: boolean; sortOrder: number; createdAt: string }

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

export default function PlansPage() {
  const [plans, setPlans] = useState<Plan[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ name: '', description: '', price: 0, interval: 'month', credits: 0, isActive: true })

  const load = async () => {
    try { const data = await apiGet<{ data: Plan[] }>('/admin/settings/pricing'); setPlans(data.data) }
    catch (e) { console.error(e) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [])

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    await apiMutate('POST', '/admin/settings/pricing', { ...form, features: {} })
    setShowForm(false)
    setForm({ name: '', description: '', price: 0, interval: 'month', credits: 0, isActive: true })
    load()
  }

  const toggleActive = async (plan: Plan) => {
    await apiMutate('PUT', `/admin/settings/pricing/${plan.id}`, { isActive: !plan.isActive })
    setPlans(prev => prev.map(p => p.id === plan.id ? { ...p, isActive: !p.isActive } : p))
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-text">Plans</h1><p className="text-sm text-text-muted">Manage subscription plans and pricing</p></div>
        <button onClick={() => setShowForm(!showForm)} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-primary text-white text-sm hover:bg-primary-hover"><Plus className="w-4 h-4" /> Add Plan</button>
      </div>
      {showForm && (
        <form onSubmit={handleCreate} className="mb-6 p-4 rounded-xl bg-surface border border-border space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <input placeholder="Plan Name" value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
            <input type="number" placeholder="Price (cents)" value={form.price || ''} onChange={e => setForm({...form, price: parseInt(e.target.value) || 0})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
            <input placeholder="Interval (month/year)" value={form.interval} onChange={e => setForm({...form, interval: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
            <input type="number" placeholder="Credits" value={form.credits || ''} onChange={e => setForm({...form, credits: parseInt(e.target.value) || 0})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
          </div>
          <input placeholder="Description" value={form.description} onChange={e => setForm({...form, description: e.target.value})} className="w-full h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
          <button type="submit" className="px-3 py-1.5 rounded-lg bg-primary text-white text-sm">Create</button>
        </form>
      )}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {plans.map(plan => (
          <div key={plan.id} className={`rounded-xl border p-5 ${plan.isActive ? 'bg-surface border-border' : 'bg-surface/50 border-border opacity-60'}`}>
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-lg font-bold text-text">{plan.name}</h3>
              {plan.isActive && <CheckCircle className="w-4 h-4 text-success" />}
            </div>
            <p className="text-3xl font-bold text-text mb-1">${(plan.price / 100).toFixed(2)}<span className="text-sm text-text-muted font-normal">/{plan.interval}</span></p>
            <p className="text-xs text-text-muted mb-3">{plan.credits} credits</p>
            {plan.description && <p className="text-xs text-text-secondary mb-4">{plan.description}</p>}
            <button onClick={() => toggleActive(plan)} className={`w-full py-1.5 rounded-lg text-xs transition-colors ${plan.isActive ? 'bg-danger/10 text-danger hover:bg-danger/20' : 'bg-primary/10 text-primary hover:bg-primary/20'}`}>
              {plan.isActive ? 'Deactivate' : 'Activate'}
            </button>
          </div>
        ))}
      </div>
    </AdminLayout>
  )
}
