'use client'

import { useState } from 'react'
import { useAuditLogs } from '@/hooks/admin/useAdminAuditLogs'
import { DataTable } from '@/components/admin/DataTable'
import { PageHeader } from '@/components/admin/PageHeader'
import { type ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import type { AuditLog } from '@/types/admin'
import { History } from 'lucide-react'

export default function AuditLogsPage() {
  const [page, setPage] = useState(0)
  const { data, isLoading } = useAuditLogs(page + 1)

  const columns: ColumnDef<AuditLog>[] = [
    {
      accessorKey: 'action',
      header: 'Action',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-surface-hover">
            <History className="h-4 w-4 text-text-muted" />
          </div>
          <div>
            <p className="font-medium text-text font-mono text-xs">{row.original.action}</p>
            <p className="text-xs text-text-muted">{row.original.entity} #{row.original.entityId}</p>
          </div>
        </div>
      ),
    },
    {
      accessorKey: 'userName',
      header: 'User',
      cell: ({ row }) => <span className="text-text-secondary">{row.original.userName}</span>,
    },
    {
      accessorKey: 'details',
      header: 'Details',
      cell: ({ row }) => (
        <span className="text-text-muted text-xs font-mono">
          {JSON.stringify(row.original.details).slice(0, 50)}
        </span>
      ),
    },
    {
      accessorKey: 'ip',
      header: 'IP',
      cell: ({ row }) => <span className="text-text-muted text-xs font-mono">{row.original.ip}</span>,
    },
    {
      accessorKey: 'createdAt',
      header: 'Timestamp',
      cell: ({ row }) => (
        <span className="text-text-muted text-xs">
          {format(new Date(row.original.createdAt), 'MMM d, yyyy HH:mm:ss')}
        </span>
      ),
    },
  ]

  return (
    <div>
      <PageHeader title="Audit Logs" description="Track all administrative actions" />
      <DataTable
        columns={columns}
        data={data?.data ?? []}
        pageCount={data?.totalPages}
        pageIndex={page}
        onPageChange={setPage}
        loading={isLoading}
      />
    </div>
  )
}
