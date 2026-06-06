'use client'

import { ContentList } from '@/components/admin/ContentList'
import { type ColumnDef } from '@tanstack/react-table'

const extraColumns: ColumnDef<any>[] = [
  {
    accessorKey: 'family',
    header: 'Family',
    cell: ({ row }) => <span className="text-text-secondary">{row.original.family || row.original.name}</span>,
  },
]

export default function FontsPage() {
  return (
    <ContentList
      type="fonts"
      title="Fonts"
      description="Manage typography and font assets"
      extraColumns={extraColumns}
    />
  )
}
