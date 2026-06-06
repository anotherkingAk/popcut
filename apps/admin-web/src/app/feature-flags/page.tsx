'use client'

import { useEffect, useState } from 'react'
import { api, type FeatureFlag } from '@/lib/api'
import { AdminLayout } from '@/components/AdminLayout'
import { Plus, Trash2 } from 'lucide-react'

export default function FeatureFlagsPage() {
  const [flags, setFlags] = useState<FeatureFlag[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ name: '', description: '', enabled: false })

  const load = () => {
    const token = localStorage.getItem('admin_token')
    if (token) api.setToken(token)
    api.getFeatureFlags().then(setFlags).catch(console.error).finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    await api.createFeatureFlag(form)
    setShowForm(false)
    setForm({ name: '', description: '', enabled: false })
    load()
  }

  const toggleFlag = async (flag: FeatureFlag) => {
    await api.updateFeatureFlag(flag.id, { enabled: !flag.enabled })
    setFlags(prev => prev.map(f => f.id === flag.id ? { ...f, enabled: !f.enabled } : f))
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this flag?')) return
    await api.deleteFeatureFlag(id)
    setFlags(prev => prev.filter(f => f.id !== id))
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-text">Feature Flags</h1><p className="text-sm text-text-muted">Enable or disable features across the platform</p></div>
        <button onClick={() => setShowForm(!showForm)} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-primary text-white text-sm hover:bg-primary-hover transition-colors"><Plus className="w-4 h-4" /> Add Flag</button>
      </div>
      {showForm && (
        <form onSubmit={handleCreate} className="mb-6 p-4 rounded-xl bg-surface border border-border space-y-3">
          <input placeholder="Flag name (e.g. new-editor)" value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="w-full h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
          <input placeholder="Description" value={form.description} onChange={e => setForm({...form, description: e.target.value})} className="w-full h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
          <button type="submit" className="px-3 py-1.5 rounded-lg bg-primary text-white text-sm">Create</button>
        </form>
      )}
      <div className="space-y-2">
        {flags.map(flag => (
          <div key={flag.id} className="flex items-center justify-between p-4 rounded-xl bg-surface border border-border">
            <div>
              <div className="flex items-center gap-2">
                <p className="text-sm font-medium text-text">{flag.name}</p>
                <div className={`w-2 h-2 rounded-full ${flag.enabled ? 'bg-success' : 'bg-text-muted'}`} />
              </div>
              {flag.description && <p className="text-xs text-text-muted mt-0.5">{flag.description}</p>}
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => toggleFlag(flag)}
                className={`relative w-10 h-5 rounded-full transition-colors ${flag.enabled ? 'bg-primary' : 'bg-border'}`}
              >
                <div className={`absolute top-0.5 w-4 h-4 rounded-full bg-white transition-transform ${flag.enabled ? 'translate-x-5' : 'translate-x-0.5'}`} />
              </button>
              <button onClick={() => handleDelete(flag.id)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-danger"><Trash2 className="w-4 h-4" /></button>
            </div>
          </div>
        ))}
        {flags.length === 0 && <p className="text-text-muted text-sm text-center py-8">No feature flags yet</p>}
      </div>
    </AdminLayout>
  )
}
