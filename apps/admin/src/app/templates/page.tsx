'use client'

import { useEffect, useState } from 'react'
import { api, type Template } from '@/lib/api'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'
import { Plus, Trash2, Edit2 } from 'lucide-react'

export default function TemplatesPage() {
  const [templates, setTemplates] = useState<Template[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ name: '', description: '', category: 'general', isPublic: true, isPremium: false })

  const load = () => {
    const token = localStorage.getItem('admin_token')
    if (token) api.setToken(token)
    api.getTemplates().then(r => setTemplates(r.data)).catch(console.error).finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    await api.createTemplate({ ...form, data: {}, tags: [] })
    setShowForm(false)
    setForm({ name: '', description: '', category: 'general', isPublic: true, isPremium: false })
    load()
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this template?')) return
    await api.deleteTemplate(id)
    setTemplates(prev => prev.filter(t => t.id !== id))
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-text">Templates</h1><p className="text-sm text-text-muted">Manage video templates</p></div>
        <button onClick={() => setShowForm(!showForm)} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-primary text-white text-sm hover:bg-primary-hover transition-colors"><Plus className="w-4 h-4" /> Add Template</button>
      </div>

      {showForm && (
        <form onSubmit={handleCreate} className="mb-6 p-4 rounded-xl bg-surface border border-border space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <input placeholder="Name" value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
            <input placeholder="Category" value={form.category} onChange={e => setForm({...form, category: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
          </div>
          <textarea placeholder="Description" value={form.description} onChange={e => setForm({...form, description: e.target.value})} className="w-full h-20 rounded-lg bg-background border border-border px-3 py-2 text-sm text-text outline-none focus:border-primary" />
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2 text-sm text-text-secondary"><input type="checkbox" checked={form.isPublic} onChange={e => setForm({...form, isPublic: e.target.checked})} /> Public</label>
            <label className="flex items-center gap-2 text-sm text-text-secondary"><input type="checkbox" checked={form.isPremium} onChange={e => setForm({...form, isPremium: e.target.checked})} /> Premium</label>
            <button type="submit" className="ml-auto px-3 py-1.5 rounded-lg bg-primary text-white text-sm">Create</button>
          </div>
        </form>
      )}

      <div className="rounded-xl bg-surface border border-border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="border-b border-border text-text-muted text-xs uppercase">
              <th className="text-left px-4 py-3 font-medium">Name</th><th className="text-left px-4 py-3 font-medium">Category</th>
              <th className="text-left px-4 py-3 font-medium">Status</th><th className="text-left px-4 py-3 font-medium">Usage</th>
              <th className="text-left px-4 py-3 font-medium">Created</th><th className="text-right px-4 py-3 font-medium">Actions</th>
            </tr></thead>
            <tbody>
              {templates.map(t => (
                <tr key={t.id} className="border-b border-border last:border-0 hover:bg-surface-hover">
                  <td className="px-4 py-3 text-text font-medium">{t.name}</td>
                  <td className="px-4 py-3 text-text-muted">{t.category}</td>
                  <td className="px-4 py-3">
                    {t.isPremium ? <span className="text-xs text-warning">Premium</span> : t.isPublic ? <span className="text-xs text-success">Public</span> : <span className="text-xs text-text-muted">Private</span>}
                  </td>
                  <td className="px-4 py-3 text-text-muted">{t.usageCount}</td>
                  <td className="px-4 py-3 text-text-muted text-xs">{formatDate(t.createdAt)}</td>
                  <td className="px-4 py-3 text-right">
                    <button onClick={() => handleDelete(t.id)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-danger"><Trash2 className="w-4 h-4" /></button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  )
}
