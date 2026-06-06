'use client'

import { useState } from 'react'
import { useContentList, useDeleteContent, usePublishContent, useUnpublishContent } from '@/hooks/admin/useAdminContent'
import { DataTable } from '@/components/admin/DataTable'
import { PageHeader } from '@/components/admin/PageHeader'
import { StatusBadge } from '@/components/admin/StatusBadge'
import { ConfirmDialog } from '@/components/admin/ConfirmDialog'
import { type ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import { Trash2, EyeOff, Eye } from 'lucide-react'

interface ContentListProps {
  type: 'templates' | 'effects' | 'filters' | 'fonts' | 'audio' | 'transitions' | 'color-grades'
  title: string
  description: string
  icon?: React.ReactNode
  extraColumns?: ColumnDef<any>[]
}

export function ContentList({ type, title, description, extraColumns = [] }: ContentListProps) {
  const [page, setPage] = useState(0)
  const [deleteId, setDeleteId] = useState<string | null>(null)
  const { data, isLoading } = useContentList(type, page + 1)
  const deleteContent = useDeleteContent(type)
  const publishContent = usePublishContent(type)
  const unpublishContent = useUnpublishContent(type)

  const columns: ColumnDef<any>[] = [
    {
      accessorKey: 'name',
      header: 'Name',
      cell: ({ row }) => (
        <div>
          <p className="font-medium text-text">{row.original.name}</p>
          <p className="text-xs text-text-muted truncate max-w-[250px]">{row.original.description}</p>
        </div>
      ),
    },
    {
      accessorKey: 'category',
      header: 'Category',
      cell: ({ row }) => (
        <span className="capitalize text-xs text-text-secondary">{row.original.category}</span>
      ),
    },
    {
      accessorKey: 'author',
      header: 'Author',
      cell: ({ row }) => <span className="text-text-secondary text-sm">{row.original.author}</span>,
    },
    {
      accessorKey: 'usageCount',
      header: 'Usage',
      cell: ({ row }) => <span>{row.original.usageCount.toLocaleString()}</span>,
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => <StatusBadge status={row.original.status} />,
    },
    {
      accessorKey: 'version',
      header: 'Ver',
      cell: ({ row }) => <span className="text-text-muted text-xs">v{row.original.version}</span>,
    },
    {
      accessorKey: 'updatedAt',
      header: 'Updated',
      cell: ({ row }) => (
        <span className="text-text-muted text-xs">
          {format(new Date(row.original.updatedAt), 'MMM d, yyyy')}
        </span>
      ),
    },
    ...extraColumns,
    {
      id: 'actions',
      header: '',
      cell: ({ row }) => (
        <div className="flex items-center gap-1">
          {row.original.status === 'published' ? (
            <button
              onClick={() => unpublishContent.mutate(row.original.id)}
              className="p-1.5 rounded-md text-warning hover:text-warning hover:bg-warning/10"
              title="Unpublish"
            >
              <EyeOff className="h-4 w-4" />
            </button>
          ) : (
            <button
              onClick={() => publishContent.mutate(row.original.id)}
              className="p-1.5 rounded-md text-success hover:text-success hover:bg-success/10"
              title="Publish"
            >
              <Eye className="h-4 w-4" />
            </button>
          )}
          <button
            onClick={() => setDeleteId(row.original.id)}
            className="p-1.5 rounded-md text-danger hover:text-danger hover:bg-danger/10"
            title="Delete"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      ),
    },
  ]

  return (
    <div>
      <PageHeader title={title} description={description} />
      <DataTable
        columns={columns}
        data={(data as any)?.data ?? []}
        pageCount={(data as any)?.totalPages}
        pageIndex={page}
        onPageChange={setPage}
        loading={isLoading}
      />
      <ConfirmDialog
        open={!!deleteId}
        onOpenChange={() => setDeleteId(null)}
        title={`Delete ${title.slice(0, -1)}`}
        description="Are you sure you want to delete this item? This action cannot be undone."
        confirmLabel="Delete"
        variant="danger"
        onConfirm={() => {
          if (deleteId) deleteContent.mutate(deleteId)
          setDeleteId(null)
        }}
        loading={deleteContent.isPending}
      />
    </div>
  )
}
