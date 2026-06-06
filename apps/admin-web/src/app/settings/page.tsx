'use client'

import { useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'
import { Shield, Flag, RefreshCw, Database, CreditCard, Cpu, Download } from 'lucide-react'

const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

export default function SettingsPage() {
  const [maintenance, setMaintenance] = useState(false)
  const [toggling, setToggling] = useState(false)

  const toggleMaintenance = async () => {
    setToggling(true)
    try {
      const token = localStorage.getItem('admin_token')
      const res = await fetch(`${API}/api/v1/admin/settings/maintenance`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ enabled: !maintenance }),
      })
      const data = await res.json()
      setMaintenance(data.enabled)
    } catch (e) { console.error(e) }
    finally { setToggling(false) }
  }

  const triggerBackup = async () => {
    const token = localStorage.getItem('admin_token')
    await fetch(`${API}/api/v1/admin/settings/backup`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
    alert('Backup initiated')
  }

  const triggerForceUpdate = async () => {
    if (!confirm('Send force update to all clients?')) return
    const token = localStorage.getItem('admin_token')
    await fetch(`${API}/api/v1/admin/settings/force-update`, { method: 'POST', headers: { Authorization: `Bearer ${token}` } })
    alert('Force update sent')
  }

  const sections = [
    { title: 'Owner Controls', icon: Shield, items: [
      { label: 'Maintenance Mode', desc: 'Put platform in maintenance mode', action: toggleMaintenance, button: maintenance ? 'Disable' : 'Enable', color: maintenance ? 'bg-success/10 text-success' : 'bg-danger/10 text-danger' },
      { label: 'Force Update', desc: 'Force all clients to update', action: triggerForceUpdate, button: 'Send', color: 'bg-primary/10 text-primary' },
      { label: 'Database Backup', desc: 'Trigger manual database backup', action: triggerBackup, button: 'Backup', color: 'bg-primary/10 text-primary' },
    ]},
    { title: 'System', icon: Cpu, items: [
      { label: 'Feature Flags', desc: 'Manage feature flags', button: 'Go to Flags', href: '/feature-flags', color: 'bg-primary/10 text-primary' },
      { label: 'Audit Logs', desc: 'View system audit trail', button: 'View Logs', href: '/audit-logs', color: 'bg-primary/10 text-primary' },
    ]},
    { title: 'Monetization', icon: CreditCard, items: [
      { label: 'Pricing Plans', desc: 'Manage subscription plans', button: 'Edit Plans', href: '/monetization/plans', color: 'bg-primary/10 text-primary' },
      { label: 'Coupons', desc: 'Manage discount coupons', button: 'Edit Coupons', href: '/monetization/coupons', color: 'bg-primary/10 text-primary' },
    ]},
  ]

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">Settings</h1><p className="text-sm text-text-muted">Owner-only platform controls</p></div>
      {sections.map(section => (
        <div key={section.title} className="mb-6">
          <div className="flex items-center gap-2 mb-3">
            <section.icon className="w-4 h-4 text-primary" />
            <h2 className="text-sm font-semibold text-text">{section.title}</h2>
          </div>
          <div className="space-y-2">
            {section.items.map(item => (
              <div key={item.label} className="flex items-center justify-between p-4 rounded-xl bg-surface border border-border">
                <div>
                  <p className="text-sm text-text font-medium">{item.label}</p>
                  <p className="text-xs text-text-muted">{item.desc}</p>
                </div>
                {'href' in item ? (
                  <a href={item.href} className={`px-3 py-1.5 rounded-lg text-xs ${item.color}`}>{item.button}</a>
                ) : (
                  <button onClick={item.action} disabled={toggling} className={`px-3 py-1.5 rounded-lg text-xs ${item.color} disabled:opacity-50`}>
                    {item.button}
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>
      ))}
    </AdminLayout>
  )
}
