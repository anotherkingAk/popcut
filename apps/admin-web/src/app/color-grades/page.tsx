'use client'

import { useEffect, useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'
import { Plus, Trash2, CheckCircle, XCircle } from 'lucide-react'

interface ColorGrade {
  id: string; name: string; type: string; category: string
  isPublic: boolean; isPremium: boolean; createdAt: string
}

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

export default function ColorGradesPage() {
  const [items, setItems] = useState<ColorGrade[]>([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ name: '', type: 'lut', category: 'cinematic', isPublic: true, isPremium: false })

  const load = async () => {
    try {
      const data = await apiGet<{ data: ColorGrade[] }>('/admin/color-grades?page=1&limit=50')
      setItems(data.data)
    } catch (e) { console.error(e) }
    finally { setLoading(false) }
  }
  useEffect(() => { load() }, [])

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    await apiMutate('POST', '/admin/color-grades', { ...form, config: {} })
    setShowForm(false)
    setForm({ name: '', type: 'lut', category: 'cinematic', isPublic: true, isPremium: false })
    load()
  }

  const togglePublish = async (item: ColorGrade) => {
    const endpoint = item.isPublic ? 'unpublish' : 'publish'
    await apiMutate('PUT', `/admin/color-grades/${item.id}/${endpoint}`)
    load()
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this color grade?')) return
    await apiMutate('DELETE', `/admin/color-grades/${id}`)
    setItems(prev => prev.filter(i => i.id !== id))
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-text">Color Grades</h1><p className="text-sm text-text-muted">Manage LUTs and color grading presets</p></div>
        <button onClick={() => setShowForm(!showForm)} className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-primary text-white text-sm hover:bg-primary-hover"><Plus className="w-4 h-4" /> Add Color Grade</button>
      </div>
      {showForm && (
        <form onSubmit={handleCreate} className="mb-6 p-4 rounded-xl bg-surface border border-border space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <input placeholder="Name" value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" required />
            <input placeholder="Category" value={form.category} onChange={e => setForm({...form, category: e.target.value})} className="h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary" />
          </div>
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2 text-sm text-text-secondary"><input type="checkbox" checked={form.isPublic} onChange={e => setForm({...form, isPublic: e.target.checked})} /> Public</label>
            <label className="flex items-center gap-2 text-sm text-text-secondary"><input type="checkbox" checked={form.isPremium} onChange={e => setForm({...form, isPremium: e.target.checked})} /> Premium</label>
            <button type="submit" className="ml-auto px-3 py-1.5 rounded-lg bg-primary text-white text-sm">Create</button>
          </div>
        </form>
      )}
      <div className="rounded-xl bg-surface border border-border overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="border-b border-border text-text-muted text-xs uppercase">
            <th className="text-left px-4 py-3 font-medium">Name</th><th className="text-left px-4 py-3 font-medium">Type</th>
            <th className="text-left px-4 py-3 font-medium">Category</th><th className="text-left px-4 py-3 font-medium">Status</th>
            <th className="text-left px-4 py-3 font-medium">Created</th><th className="text-right px-4 py-3 font-medium">Actions</th>
          </tr></thead>
          <tbody>
            {items.map(item => (
              <tr key={item.id} className="border-b border-border last:border-0 hover:bg-surface-hover">
                <td className="px-4 py-3 text-text font-medium">{item.name}</td>
                <td className="px-4 py-3"><span className="px-2 py-0.5 rounded-full bg-surface-hover text-text-secondary text-xs">{item.type}</span></td>
                <td className="px-4 py-3 text-text-muted">{item.category}</td>
                <td className="px-4 py-3">{item.isPremium ? <span className="text-warning text-xs">Premium</span> : item.isPublic ? <span className="text-success text-xs">Published</span> : <span className="text-text-muted text-xs">Unpublished</span>}</td>
                <td className="px-4 py-3 text-text-muted text-xs">{formatDate(item.createdAt)}</td>
                <td className="px-4 py-3 text-right flex items-center justify-end gap-1">
                  <button onClick={() => togglePublish(item)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-success">{item.isPublic ? <XCircle className="w-4 h-4" /> : <CheckCircle className="w-4 h-4" />}</button>
                  <button onClick={() => handleDelete(item.id)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-danger"><Trash2 className="w-4 h-4" /></button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AdminLayout>
  )
}
