'use client'

import { ContentList } from '@/components/admin/ContentList'
import { type ColumnDef } from '@tanstack/react-table'

const extraColumns: ColumnDef<any>[] = [
  {
    accessorKey: 'type',
    header: 'Type',
    cell: ({ row }) => (
      <span className="capitalize text-xs text-text-secondary">{row.original.type}</span>
    ),
  },
]

export default function TransitionsPage() {
  return (
    <ContentList
      type="transitions"
      title="Transitions"
      description="Manage scene transitions"
      extraColumns={extraColumns}
    />
  )
}
