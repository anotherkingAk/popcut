'use client'

import { useEffect, useState } from 'react'
import { api, type AuditLog } from '@/lib/api'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'

export default function AuditLogsPage() {
  const [logs, setLogs] = useState<AuditLog[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (token) api.setToken(token)
    api.getAuditLogs().then(r => setLogs(r.data)).catch(console.error).finally(() => setLoading(false))
  }, [])

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">Audit Logs</h1><p className="text-sm text-text-muted">Complete audit trail of all system actions</p></div>
      <div className="rounded-xl bg-surface border border-border overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="border-b border-border text-text-muted text-xs uppercase">
            <th className="text-left px-4 py-3 font-medium">User</th><th className="text-left px-4 py-3 font-medium">Action</th>
            <th className="text-left px-4 py-3 font-medium">Entity</th><th className="text-left px-4 py-3 font-medium">IP</th>
            <th className="text-left px-4 py-3 font-medium">Date</th>
          </tr></thead>
          <tbody>
            {logs.map(log => (
              <tr key={log.id} className="border-b border-border last:border-0 hover:bg-surface-hover">
                <td className="px-4 py-3 text-text">{log.user?.name || log.user?.email || log.userId}</td>
                <td className="px-4 py-3">
                  <span className="px-2 py-0.5 rounded-full bg-surface-hover text-text-secondary text-xs">{log.action}</span>
                </td>
                <td className="px-4 py-3 text-text-muted text-xs">{log.entity ? `${log.entity}${log.entityId ? ` #${log.entityId.slice(0, 8)}` : ''}` : '-'}</td>
                <td className="px-4 py-3 text-text-muted text-xs font-mono">{log.ip || '-'}</td>
                <td className="px-4 py-3 text-text-muted text-xs">{formatDate(log.createdAt)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AdminLayout>
  )
}
