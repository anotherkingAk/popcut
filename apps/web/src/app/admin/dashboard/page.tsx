'use client'

import { useDashboardMetrics, useAnalyticsData } from '@/hooks/admin/useAdminDashboard'
import { StatCard } from '@/components/admin/StatCard'
import { ChartCard } from '@/components/admin/ChartCard'
import { PageHeader } from '@/components/admin/PageHeader'
import {
  LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, AreaChart, Area,
} from 'recharts'
import {
  Users, Activity, DollarSign, Upload, Cpu, HardDrive,
} from 'lucide-react'
import { useState } from 'react'
import { cn } from '@/lib/utils'

const periods = [
  { label: '7 Days', value: '7d' },
  { label: '30 Days', value: '30d' },
  { label: '90 Days', value: '90d' },
]

export default function DashboardPage() {
  const { data: metrics, isLoading: metricsLoading } = useDashboardMetrics()
  const [period, setPeriod] = useState('30d')
  const { data: analytics } = useAnalyticsData(period)

  const CustomTooltip = ({ active, payload, label }: any) => {
    if (!active || !payload?.length) return null
    return (
      <div className="rounded-lg border border-border bg-surface p-3 shadow-lg">
        <p className="text-xs text-text-muted mb-1">{label}</p>
        {payload.map((entry: any, i: number) => (
          <p key={i} className="text-sm font-medium text-text" style={{ color: entry.color }}>
            {entry.name}: {entry.value.toLocaleString()}
          </p>
        ))}
      </div>
    )
  }

  return (
    <div>
      <PageHeader
        title="Dashboard"
        description="Overview of your PopCut platform"
      />

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4 mb-6">
        <StatCard title="Daily Active Users" value={metrics?.dau ?? '...'} icon={Activity} />
        <StatCard title="Monthly Active Users" value={metrics?.mau ?? '...'} icon={Users} />
        <StatCard title="Revenue" value={metrics ? `$${metrics.revenue.toLocaleString()}` : '...'} change={metrics?.revenueChange} icon={DollarSign} />
        <StatCard title="Active Exports" value={metrics?.activeExports ?? '...'} icon={Upload} />
        <StatCard title="AI Usage" value={metrics?.aiUsage ?? '...'} icon={Cpu} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6">
        <ChartCard title="Active Users">
          <div className="flex gap-1 mb-4">
            {periods.map((p) => (
              <button
                key={p.value}
                onClick={() => setPeriod(p.value)}
                className={cn(
                  'px-3 py-1 rounded-lg text-xs font-medium transition-colors',
                  period === p.value
                    ? 'bg-primary text-white'
                    : 'bg-surface-hover text-text-secondary hover:text-text'
                )}
              >
                {p.label}
              </button>
            ))}
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={analytics?.dailyActiveUsers}>
                <defs>
                  <linearGradient id="userGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#6366f1" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 11, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Area type="monotone" dataKey="value" stroke="#6366f1" fill="url(#userGradient)" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>

        <ChartCard title="Revenue">
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={analytics?.revenue}>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 11, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Bar dataKey="value" fill="#22d3ee" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6">
        <ChartCard title="User Growth">
          <div className="h-48">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={analytics?.userGrowth}>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Line type="monotone" dataKey="value" stroke="#22c55e" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>

        <ChartCard title="Exports">
          <div className="h-48">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={analytics?.exports}>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Line type="monotone" dataKey="value" stroke="#f59e0b" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>

        <ChartCard title="AI Usage">
          <div className="h-48">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={analytics?.aiUsage}>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Line type="monotone" dataKey="value" stroke="#a855f7" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <StatCard title="Total Users" value={metrics?.totalUsers?.toLocaleString() ?? '...'} icon={Users} />
        <StatCard title="New Users Today" value={metrics?.newUsersToday ?? '...'} icon={Activity} />
        <StatCard title="Total Projects" value={metrics?.totalProjects?.toLocaleString() ?? '...'} icon={Upload} />
        <StatCard title="Storage Used" value={metrics ? `${metrics.storageUsed} GB` : '...'} icon={HardDrive} />
      </div>
    </div>
  )
}
