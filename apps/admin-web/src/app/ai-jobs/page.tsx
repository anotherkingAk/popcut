'use client'

import { useEffect, useState } from 'react'
import { api, type AIJob } from '@/lib/api'
import { AdminLayout } from '@/components/AdminLayout'
import { formatDate } from '@/lib/utils'
import { RotateCcw } from 'lucide-react'

export default function AIJobsPage() {
  const [jobs, setJobs] = useState<AIJob[]>([])
  const [loading, setLoading] = useState(true)

  const load = () => {
    const token = localStorage.getItem('admin_token')
    if (token) api.setToken(token)
    api.getAIJobs().then(r => setJobs(r.data)).catch(console.error).finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])

  const retry = async (id: string) => {
    await api.retryAIJob(id)
    load()
  }

  if (loading) return <AdminLayout><div className="flex items-center justify-center h-64"><p className="text-text-muted">Loading...</p></div></AdminLayout>

  const statusColor = (s: string) => {
    switch (s) {
      case 'completed': return 'text-success'
      case 'processing': return 'text-primary'
      case 'queued': return 'text-text-muted'
      case 'failed': return 'text-danger'
      default: return 'text-text-muted'
    }
  }

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">AI Jobs</h1><p className="text-sm text-text-muted">Monitor AI processing jobs</p></div>
      <div className="rounded-xl bg-surface border border-border overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="border-b border-border text-text-muted text-xs uppercase">
            <th className="text-left px-4 py-3 font-medium">User</th><th className="text-left px-4 py-3 font-medium">Type</th>
            <th className="text-left px-4 py-3 font-medium">Status</th><th className="text-left px-4 py-3 font-medium">Progress</th>
            <th className="text-left px-4 py-3 font-medium">Error</th><th className="text-left px-4 py-3 font-medium">Created</th>
            <th className="text-right px-4 py-3 font-medium">Actions</th>
          </tr></thead>
          <tbody>
            {jobs.map(job => (
              <tr key={job.id} className="border-b border-border last:border-0 hover:bg-surface-hover">
                <td className="px-4 py-3 text-text">{job.user?.name || job.user?.email || job.userId}</td>
                <td className="px-4 py-3"><span className="px-2 py-0.5 rounded-full bg-surface-hover text-text-secondary text-xs">{job.type}</span></td>
                <td className="px-4 py-3"><span className={`text-xs font-medium ${statusColor(job.status)}`}>{job.status}</span></td>
                <td className="px-4 py-3">
                  <div className="flex items-center gap-2">
                    <div className="w-20 h-1.5 rounded-full bg-border overflow-hidden"><div className="h-full bg-primary rounded-full" style={{ width: `${job.progress}%` }} /></div>
                    <span className="text-xs text-text-muted">{job.progress}%</span>
                  </div>
                </td>
                <td className="px-4 py-3 text-danger text-xs max-w-[150px] truncate">{job.error || '-'}</td>
                <td className="px-4 py-3 text-text-muted text-xs">{formatDate(job.createdAt)}</td>
                <td className="px-4 py-3 text-right">
                  {job.status === 'failed' && <button onClick={() => retry(job.id)} className="p-1.5 rounded hover:bg-surface-hover text-text-muted hover:text-primary" title="Retry"><RotateCcw className="w-4 h-4" /></button>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </AdminLayout>
  )
}
