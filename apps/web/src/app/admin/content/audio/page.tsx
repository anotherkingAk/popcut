'use client'

import { ContentList } from '@/components/admin/ContentList'
import { type ColumnDef } from '@tanstack/react-table'

const extraColumns: ColumnDef<any>[] = [
  {
    accessorKey: 'artist',
    header: 'Artist',
    cell: ({ row }) => <span className="text-text-secondary">{row.original.artist || 'Unknown'}</span>,
  },
  {
    accessorKey: 'duration',
    header: 'Duration',
    cell: ({ row }) => {
      const mins = Math.floor((row.original.duration || 0) / 60)
      const secs = (row.original.duration || 0) % 60
      return <span>{mins}:{secs.toString().padStart(2, '0')}</span>
    },
  },
]

export default function AudioPage() {
  return (
    <ContentList
      type="audio"
      title="Audio"
      description="Manage audio tracks and sound effects"
      extraColumns={extraColumns}
    />
  )
}
