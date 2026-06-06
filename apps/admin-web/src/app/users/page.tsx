'use client'

import { useEffect, useState } from 'react'
import { api, type User } from '@/lib/api'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'
import { Shield, ShieldOff, Trash2 } from 'lucide-react'

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (token) api.setToken(token)
    api.getUsers().then(r => setUsers(r.data)).catch(console.error).finally(() => setLoading(false))
  }, [])

  const toggleActive = async (user: User) => {
    await api.updateUser(user.id, { isActive: !user.isActive })
    setUsers(prev => prev.map(u => u.id === user.id ? { ...u, isActive: !u.isActive } : u))
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this user?')) return
    await api.deleteUser(id)
    setUsers(prev => prev.filter(u => u.id !== id))
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">Users</h1><p className="text-sm text-text-muted">Manage all users</p></div>
      <div className="rounded-xl bg-surface border border-border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="border-b border-border text-text-muted text-xs uppercase">
              <th className="text-left px-4 py-3 font-medium">User</th><th className="text-left px-4 py-3 font-medium">Role</th>
              <th className="text-left px-4 py-3 font-medium">Credits</th><th className="text-left px-4 py-3 font-medium">Status</th>
              <th className="text-left px-4 py-3 font-medium">Joined</th><th className="text-right px-4 py-3 font-medium">Actions</th>
            </tr></thead>
            <tbody>
              {users.map(user => (
                <tr key={user.id} className="border-b border-border last:border-0 hover:bg-surface-hover">
                  <td className="px-4 py-3">
                    <p className="text-text font-medium">{user.name || 'Unnamed'}</p>
                    <p className="text-text-muted text-xs">{user.email}</p>
                  </td>
                  <td className="px-4 py-3"><span className="px-2 py-0.5 rounded-full bg-primary/10 text-primary text-xs capitalize">{user.role.toLowerCase()}</span></td>
                  <td className="px-4 py-3 text-text">{user.credits}</td>
                  <td className="px-4 py-3">{user.isActive ? <span className="text-success text-xs">Active</span> : <span className="text-danger text-xs">Disabled</span>}</td>
                  <td className="px-4 py-3 text-text-muted text-xs">{formatDate(user.createdAt)}</td>
                  <td className="px-4 py-3 text-right">
                    <button onClick={() => toggleActive(user)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-warning" title="Toggle active">{user.isActive ? <ShieldOff className="w-4 h-4" /> : <Shield className="w-4 h-4" />}</button>
                    <button onClick={() => handleDelete(user.id)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-danger" title="Delete"><Trash2 className="w-4 h-4" /></button>
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
