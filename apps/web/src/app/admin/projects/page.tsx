'use client'

import { useState } from 'react'
import { useProjects, useDeleteProject } from '@/hooks/admin/useAdminProjects'
import { DataTable } from '@/components/admin/DataTable'
import { PageHeader } from '@/components/admin/PageHeader'
import { StatusBadge } from '@/components/admin/StatusBadge'
import { ConfirmDialog } from '@/components/admin/ConfirmDialog'
import { Button } from '@/components/ui/button'
import { type ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import type { Project } from '@/types/admin'
import { Trash2, Film } from 'lucide-react'

export default function ProjectsPage() {
  const [page, setPage] = useState(0)
  const [deleteId, setDeleteId] = useState<string | null>(null)
  const { data, isLoading } = useProjects(page + 1)
  const deleteProject = useDeleteProject()

  const columns: ColumnDef<Project>[] = [
    {
      accessorKey: 'name',
      header: 'Project',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-accent/10">
            <Film className="h-4 w-4 text-accent" />
          </div>
          <div>
            <p className="font-medium text-text">{row.original.name}</p>
            <p className="text-xs text-text-muted">{row.original.userName}</p>
          </div>
        </div>
      ),
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => <StatusBadge status={row.original.status} />,
    },
    {
      accessorKey: 'duration',
      header: 'Duration',
      cell: ({ row }) => {
        const mins = Math.floor(row.original.duration / 60)
        const secs = row.original.duration % 60
        return <span className="text-text-secondary">{mins}:{secs.toString().padStart(2, '0')}</span>
      },
    },
    {
      accessorKey: 'exportsCount',
      header: 'Exports',
      cell: ({ row }) => <span>{row.original.exportsCount}</span>,
    },
    {
      accessorKey: 'createdAt',
      header: 'Created',
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
        <button
          onClick={() => setDeleteId(row.original.id)}
          className="p-1.5 rounded-md text-danger hover:text-danger hover:bg-danger/10"
        >
          <Trash2 className="h-4 w-4" />
        </button>
      ),
    },
  ]

  return (
    <div>
      <PageHeader title="Projects" description="View and manage all user projects" />
      <DataTable
        columns={columns}
        data={data?.data ?? []}
        pageCount={data?.totalPages}
        pageIndex={page}
        onPageChange={setPage}
        loading={isLoading}
      />
      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title="Delete Project"
        description="Are you sure you want to delete this project? This cannot be undone."
        confirmLabel="Delete"
        variant="danger"
        onConfirm={() => {
          if (deleteId) deleteProject.mutate(deleteId)
          setDeleteId(null)
        }}
        loading={deleteProject.isPending}
      />
    </div>
  )
}
