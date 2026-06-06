'use client'

import { useState } from 'react'
import { useUsers, useDeleteUser, useSuspendUser, useUnsuspendUser, useAssignCredits } from '@/hooks/admin/useAdminUsers'
import { DataTable } from '@/components/admin/DataTable'
import { PageHeader } from '@/components/admin/PageHeader'
import { StatusBadge } from '@/components/admin/StatusBadge'
import { SearchInput } from '@/components/admin/SearchInput'
import { ConfirmDialog } from '@/components/admin/ConfirmDialog'
import { EmptyState } from '@/components/admin/EmptyState'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { type ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import type { AdminUser } from '@/types/admin'
import { Trash2, Ban, CheckCircle, Coins, Eye, Users } from 'lucide-react'

export default function UsersPage() {
  const [page, setPage] = useState(0)
  const [search, setSearch] = useState('')
  const [viewUser, setViewUser] = useState<AdminUser | null>(null)
  const [deleteId, setDeleteId] = useState<string | null>(null)
  const [suspendId, setSuspendId] = useState<string | null>(null)
  const [creditUserId, setCreditUserId] = useState<string | null>(null)
  const [creditAmount, setCreditAmount] = useState('')
  const { data, isLoading } = useUsers(page + 1)
  const deleteUser = useDeleteUser()
  const suspendUser = useSuspendUser()
  const unsuspendUser = useUnsuspendUser()
  const assignCredits = useAssignCredits()

  const filtered = search
    ? {
        ...data,
        data: data?.data.filter(
          (u) =>
            u.name?.toLowerCase().includes(search.toLowerCase()) ||
            u.email.toLowerCase().includes(search.toLowerCase())
        ) ?? [],
      }
    : data

  const columns: ColumnDef<AdminUser>[] = [
    {
      accessorKey: 'email',
      header: 'User',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/20 text-primary text-xs font-bold">
            {(row.original.name || row.original.email)[0].toUpperCase()}
          </div>
          <div>
            <p className="font-medium text-text">{row.original.name || 'Unnamed'}</p>
            <p className="text-xs text-text-muted">{row.original.email}</p>
          </div>
        </div>
      ),
    },
    {
      accessorKey: 'role',
      header: 'Role',
      cell: ({ row }) => (
        <span className="capitalize text-xs text-text-secondary">{row.original.role}</span>
      ),
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => <StatusBadge status={row.original.status} />,
    },
    {
      accessorKey: 'credits',
      header: 'Credits',
      cell: ({ row }) => <span>{row.original.credits.toLocaleString()}</span>,
    },
    {
      accessorKey: 'projectsCount',
      header: 'Projects',
      cell: ({ row }) => <span>{row.original.projectsCount}</span>,
    },
    {
      accessorKey: 'createdAt',
      header: 'Joined',
      cell: ({ row }) => (
        <span className="text-text-muted text-xs">
          {format(new Date(row.original.createdAt), 'MMM d, yyyy')}
        </span>
      ),
    },
    {
      id: 'actions',
      header: '',
      cell: ({ row }) => (
        <div className="flex items-center gap-1">
          <button
            onClick={() => setViewUser(row.original)}
            className="p-1.5 rounded-md text-text-muted hover:text-text hover:bg-surface-hover"
          >
            <Eye className="h-4 w-4" />
          </button>
          <button
            onClick={() => setCreditUserId(row.original.id)}
            className="p-1.5 rounded-md text-text-muted hover:text-text hover:bg-surface-hover"
          >
            <Coins className="h-4 w-4" />
          </button>
          {row.original.status === 'active' ? (
            <button
              onClick={() => setSuspendId(row.original.id)}
              className="p-1.5 rounded-md text-warning hover:text-warning hover:bg-warning/10"
            >
              <Ban className="h-4 w-4" />
            </button>
          ) : (
            <button
              onClick={() => unsuspendUser.mutate(row.original.id)}
              className="p-1.5 rounded-md text-success hover:text-success hover:bg-success/10"
            >
              <CheckCircle className="h-4 w-4" />
            </button>
          )}
          <button
            onClick={() => setDeleteId(row.original.id)}
            className="p-1.5 rounded-md text-danger hover:text-danger hover:bg-danger/10"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      ),
    },
  ]

  return (
    <div>
      <PageHeader title="Users" description="Manage platform users" />

      <div className="mb-4">
        <SearchInput value={search} onChange={setSearch} placeholder="Search users..." />
      </div>

      <DataTable
        columns={columns}
        data={filtered?.data ?? []}
        pageCount={filtered?.totalPages}
        pageIndex={page}
        onPageChange={setPage}
        loading={isLoading}
      />

      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title="Delete User"
        description="Are you sure you want to delete this user? This action cannot be undone."
        confirmLabel="Delete"
        variant="danger"
        onConfirm={() => {
          if (deleteId) deleteUser.mutate(deleteId)
          setDeleteId(null)
        }}
        loading={deleteUser.isPending}
      />

      <ConfirmDialog
        open={!!suspendId}
        onOpenChange={() => setSuspendId(null)}
        title="Suspend User"
        description="This user will lose access to the platform until reinstated."
        confirmLabel="Suspend"
        variant="danger"
        onConfirm={() => {
          if (suspendId) suspendUser.mutate(suspendId)
          setSuspendId(null)
        }}
        loading={suspendUser.isPending}
      />

      <Dialog open={!!creditUserId} onOpenChange={() => setCreditUserId(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Assign Credits</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Credit Amount</label>
              <Input
                type="number"
                value={creditAmount}
                onChange={(e) => setCreditAmount(e.target.value)}
                placeholder="Enter amount..."
              />
            </div>
            <Button
              className="w-full"
              onClick={() => {
                if (creditUserId && creditAmount) {
                  assignCredits.mutate({
                    userId: creditUserId,
                    amount: parseInt(creditAmount),
                  })
                }
                setCreditUserId(null)
                setCreditAmount('')
              }}
              disabled={!creditAmount || assignCredits.isPending}
            >
              {assignCredits.isPending ? 'Assigning...' : 'Assign Credits'}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <Dialog open={!!viewUser} onOpenChange={() => setViewUser(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>User Details</DialogTitle>
          </DialogHeader>
          {viewUser && (
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary/20 text-primary text-xl font-bold">
                  {(viewUser.name || viewUser.email)[0].toUpperCase()}
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-text">{viewUser.name || 'Unnamed'}</h3>
                  <p className="text-sm text-text-muted">{viewUser.email}</p>
                  <StatusBadge status={viewUser.status} className="mt-1" />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3 text-sm">
                <div className="rounded-lg bg-surface-hover p-3">
                  <p className="text-text-muted text-xs">Role</p>
                  <p className="text-text font-medium capitalize">{viewUser.role}</p>
                </div>
                <div className="rounded-lg bg-surface-hover p-3">
                  <p className="text-text-muted text-xs">Credits</p>
                  <p className="text-text font-medium">{viewUser.credits.toLocaleString()}</p>
                </div>
                <div className="rounded-lg bg-surface-hover p-3">
                  <p className="text-text-muted text-xs">Projects</p>
                  <p className="text-text font-medium">{viewUser.projectsCount}</p>
                </div>
                <div className="rounded-lg bg-surface-hover p-3">
                  <p className="text-text-muted text-xs">Exports</p>
                  <p className="text-text font-medium">{viewUser.totalExports}</p>
                </div>
                <div className="rounded-lg bg-surface-hover p-3 col-span-2">
                  <p className="text-text-muted text-xs">Subscription</p>
                  <p className="text-text font-medium capitalize">{viewUser.subscriptionTier || 'Free'}</p>
                </div>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
