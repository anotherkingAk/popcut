'use client'

import { useState } from 'react'
import { useAIGenerationJobs, useSubmitAIGeneration, useReviewAIGeneration } from '@/hooks/admin/useAdminAIFactory'
import { DataTable } from '@/components/admin/DataTable'
import { PageHeader } from '@/components/admin/PageHeader'
import { StatusBadge } from '@/components/admin/StatusBadge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { type ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import type { AIGenerationJob } from '@/types/admin'
import { Sparkles, Check, X, Cpu } from 'lucide-react'

const generationTypes = [
  { value: 'effect', label: 'Generate Effect' },
  { value: 'template', label: 'Generate Template' },
  { value: 'transition', label: 'Generate Transition' },
  { value: 'metadata', label: 'Generate Metadata' },
]

export default function AIFactoryPage() {
  const [page, setPage] = useState(0)
  const [showGenerate, setShowGenerate] = useState(false)
  const [genType, setGenType] = useState('effect')
  const [prompt, setPrompt] = useState('')
  const { data, isLoading } = useAIGenerationJobs(page + 1)
  const submitJob = useSubmitAIGeneration()
  const reviewJob = useReviewAIGeneration()

  const columns: ColumnDef<AIGenerationJob>[] = [
    {
      accessorKey: 'id',
      header: 'Job',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-purple-500/10">
            <Cpu className="h-4 w-4 text-purple-500" />
          </div>
          <div>
            <p className="font-medium text-text capitalize">{row.original.type}</p>
            <p className="text-xs text-text-muted">Job #{row.original.id}</p>
          </div>
        </div>
      ),
    },
    {
      accessorKey: 'userName',
      header: 'Requested By',
      cell: ({ row }) => <span className="text-text-secondary">{row.original.userName}</span>,
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => <StatusBadge status={row.original.status} />,
    },
    {
      accessorKey: 'progress',
      header: 'Progress',
      cell: ({ row }) => (
        <div className="flex items-center gap-2">
          <div className="h-2 w-24 rounded-full bg-surface-hover overflow-hidden">
            <div
              className="h-full rounded-full bg-primary transition-all"
              style={{ width: `${row.original.progress}%` }}
            />
          </div>
          <span className="text-xs text-text-muted">{row.original.progress}%</span>
        </div>
      ),
    },
    {
      accessorKey: 'createdAt',
      header: 'Created',
      cell: ({ row }) => (
        <span className="text-text-muted text-xs">
          {format(new Date(row.original.createdAt), 'MMM d, HH:mm')}
        </span>
      ),
    },
    {
      id: 'actions',
      header: '',
      cell: ({ row }) =>
        row.original.status === 'completed' && !row.original.output?.id ? (
          <div className="flex items-center gap-1">
            <button
              onClick={() => reviewJob.mutate({ id: row.original.id, approved: true })}
              className="p-1.5 rounded-md text-success hover:text-success hover:bg-success/10"
              title="Approve"
            >
              <Check className="h-4 w-4" />
            </button>
            <button
              onClick={() => reviewJob.mutate({ id: row.original.id, approved: false })}
              className="p-1.5 rounded-md text-danger hover:text-danger hover:bg-danger/10"
              title="Reject"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        ) : null,
    },
  ]

  const handleGenerate = () => {
    submitJob.mutate({ type: genType, input: { prompt } })
    setShowGenerate(false)
    setPrompt('')
  }

  return (
    <div>
      <PageHeader
        title="AI Factory"
        description="Generate and review AI-powered content"
        actions={
          <Button onClick={() => setShowGenerate(true)}>
            <Sparkles className="h-4 w-4 mr-2" />
            New Generation
          </Button>
        }
      />

      <DataTable
        columns={columns}
        data={data?.data ?? []}
        pageCount={data?.totalPages}
        pageIndex={page}
        onPageChange={setPage}
        loading={isLoading}
      />

      <Dialog open={showGenerate} onOpenChange={setShowGenerate}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>New AI Generation</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Generation Type</label>
              <select
                value={genType}
                onChange={(e) => setGenType(e.target.value)}
                className="flex h-10 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-text focus:outline-none focus:ring-2 focus:ring-primary"
              >
                {generationTypes.map((t) => (
                  <option key={t.value} value={t.value}>{t.label}</option>
                ))}
              </select>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Prompt</label>
              <textarea
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder="Describe what you want to generate..."
                rows={4}
                className="flex w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-text placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary resize-none"
              />
            </div>
            <Button
              className="w-full"
              onClick={handleGenerate}
              disabled={!prompt || submitJob.isPending}
            >
              {submitJob.isPending ? 'Submitting...' : 'Generate'}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
