'use client'

import dynamic from 'next/dynamic'
import { useState } from 'react'
import { useAnalyticsData } from '@/hooks/admin/useAdminDashboard'
import { ChartCard } from '@/components/admin/ChartCard'
import { PageHeader } from '@/components/admin/PageHeader'
import { cn } from '@/lib/utils'

const LineChart = dynamic(() => import('recharts').then(mod => mod.LineChart), { ssr: false })
const Line = dynamic(() => import('recharts').then(mod => mod.Line), { ssr: false })
const BarChart = dynamic(() => import('recharts').then(mod => mod.BarChart), { ssr: false })
const Bar = dynamic(() => import('recharts').then(mod => mod.Bar), { ssr: false })
const AreaChart = dynamic(() => import('recharts').then(mod => mod.AreaChart), { ssr: false })
const Area = dynamic(() => import('recharts').then(mod => mod.Area), { ssr: false })
const XAxis = dynamic(() => import('recharts').then(mod => mod.XAxis), { ssr: false })
const YAxis = dynamic(() => import('recharts').then(mod => mod.YAxis), { ssr: false })
const CartesianGrid = dynamic(() => import('recharts').then(mod => mod.CartesianGrid), { ssr: false })
const Tooltip = dynamic(() => import('recharts').then(mod => mod.Tooltip), { ssr: false })
const ResponsiveContainer = dynamic(() => import('recharts').then(mod => mod.ResponsiveContainer), { ssr: false })
const PieChart = dynamic(() => import('recharts').then(mod => mod.PieChart), { ssr: false })
const Pie = dynamic(() => import('recharts').then(mod => mod.Pie), { ssr: false })
const Cell = dynamic(() => import('recharts').then(mod => mod.Cell), { ssr: false })

const periods = [
  { label: '7 Days', value: '7d' },
  { label: '30 Days', value: '30d' },
  { label: '90 Days', value: '90d' },
]

const revenueBreakdown = [
  { name: 'Subscriptions', value: 65 },
  { name: 'Credit Packs', value: 20 },
  { name: 'One-time', value: 10 },
  { name: 'Other', value: 5 },
]

const COLORS = ['#6366f1', '#22d3ee', '#22c55e', '#f59e0b']

const CustomTooltip = ({ active, payload, label }: any) => {
  if (!active || !payload?.length) return null
  return (
    <div className="rounded-lg border border-border bg-surface p-3 shadow-lg">
      <p className="text-xs text-text-muted mb-1">{label}</p>
      {payload.map((entry: any, i: number) => (
        <p key={i} className="text-sm font-medium text-text">
          {entry.name}: {entry.value.toLocaleString()}
        </p>
      ))}
    </div>
  )
}

export default function AnalyticsPage() {
  const [period, setPeriod] = useState('30d')
  const { data: analytics } = useAnalyticsData(period)

  return (
    <div>
      <PageHeader title="Analytics" description="Deep dive into platform metrics" />

      <div className="flex gap-1 mb-6">
        {periods.map((p) => (
          <button
            key={p.value}
            onClick={() => setPeriod(p.value)}
            className={cn(
              'px-3 py-1.5 rounded-lg text-xs font-medium transition-colors',
              period === p.value
                ? 'bg-primary text-white'
                : 'bg-surface-hover text-text-secondary hover:text-text'
            )}
          >
            {p.label}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6">
        <ChartCard title="Daily Active Users">
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={analytics?.dailyActiveUsers}>
                <defs>
                  <linearGradient id="dauGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#6366f1" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Area type="monotone" dataKey="value" stroke="#6366f1" fill="url(#dauGrad)" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>

        <ChartCard title="Revenue">
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={analytics?.revenue}>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Bar dataKey="value" fill="#22d3ee" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6">
        <ChartCard title="User Growth">
          <div className="h-56">
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

        <ChartCard title="Export Statistics">
          <div className="h-56">
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

        <ChartCard title="Revenue Breakdown">
          <div className="h-56 flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={revenueBreakdown}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  paddingAngle={4}
                  dataKey="value"
                >
                  {revenueBreakdown.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-wrap gap-3 mt-2">
            {revenueBreakdown.map((item, i) => (
              <div key={item.name} className="flex items-center gap-1.5">
                <div className="h-2.5 w-2.5 rounded-full" style={{ backgroundColor: COLORS[i] }} />
                <span className="text-xs text-text-secondary">{item.name} ({item.value}%)</span>
              </div>
            ))}
          </div>
        </ChartCard>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <ChartCard title="AI Usage">
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={analytics?.aiUsage}>
                <defs>
                  <linearGradient id="aiGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#a855f7" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#a855f7" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Area type="monotone" dataKey="value" stroke="#a855f7" fill="url(#aiGrad)" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>

        <ChartCard title="Storage Usage (GB)">
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={analytics?.storage}>
                <defs>
                  <linearGradient id="storageGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#22c55e" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#22c55e" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fontSize: 10, fill: '#71717a' }} tickLine={false} axisLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Area type="monotone" dataKey="value" stroke="#22c55e" fill="url(#storageGrad)" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </ChartCard>
      </div>
    </div>
  )
}
