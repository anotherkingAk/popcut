'use client'

import { useState } from 'react'
import { useSubscriptions, useUpdateSubscription, useCancelSubscription } from '@/hooks/admin/useAdminSubscriptions'
import { DataTable } from '@/components/admin/DataTable'
import { PageHeader } from '@/components/admin/PageHeader'
import { StatusBadge } from '@/components/admin/StatusBadge'
import { ConfirmDialog } from '@/components/admin/ConfirmDialog'
import { type ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import type { Subscription } from '@/types/admin'
import { Ban, CreditCard } from 'lucide-react'

export default function SubscriptionsPage() {
  const [page, setPage] = useState(0)
  const [cancelId, setCancelId] = useState<string | null>(null)
  const { data, isLoading } = useSubscriptions(page + 1)
  const cancelSubscription = useCancelSubscription()

  const columns: ColumnDef<Subscription>[] = [
    {
      accessorKey: 'userName',
      header: 'User',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10">
            <CreditCard className="h-4 w-4 text-primary" />
          </div>
          <span className="font-medium text-text">{row.original.userName}</span>
        </div>
      ),
    },
    {
      accessorKey: 'plan',
      header: 'Plan',
      cell: ({ row }) => (
        <span className="capitalize font-medium">{row.original.plan}</span>
      ),
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => <StatusBadge status={row.original.status} />,
    },
    {
      accessorKey: 'price',
      header: 'Price',
      cell: ({ row }) => (
        <span>${row.original.price.toFixed(2)}/{row.original.interval === 'monthly' ? 'mo' : 'yr'}</span>
      ),
    },
    {
      accessorKey: 'currentPeriodEnd',
      header: 'Renewal',
      cell: ({ row }) => (
        <span className="text-text-muted text-xs">
          {format(new Date(row.original.currentPeriodEnd), 'MMM d, yyyy')}
        </span>
      ),
    },
    {
      id: 'actions',
      header: '',
      cell: ({ row }) =>
        row.original.status === 'active' && (
          <button
            onClick={() => setCancelId(row.original.id)}
            className="p-1.5 rounded-md text-danger hover:text-danger hover:bg-danger/10"
            title="Cancel"
          >
            <Ban className="h-4 w-4" />
          </button>
        ),
    },
  ]

  return (
    <div>
      <PageHeader title="Subscriptions" description="Manage user subscriptions" />
      <DataTable
        columns={columns}
        data={data?.data ?? []}
        pageCount={data?.totalPages}
        pageIndex={page}
        onPageChange={setPage}
        loading={isLoading}
      />
      <ConfirmDialog
        open={!!cancelId}
        onOpenChange={() => setCancelId(null)}
        title="Cancel Subscription"
        description="The user will lose access to premium features at the end of their billing period."
        confirmLabel="Cancel Subscription"
        variant="danger"
        onConfirm={() => {
          if (cancelId) cancelSubscription.mutate(cancelId)
          setCancelId(null)
        }}
        loading={cancelSubscription.isPending}
      />
    </div>
  )
}
