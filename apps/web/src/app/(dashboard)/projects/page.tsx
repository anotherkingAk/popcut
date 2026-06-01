'use client'

import { Button } from '@/components/ui/button'
import { Plus, MoreHorizontal, Play } from 'lucide-react'
import { formatDuration } from '@/lib/utils'

const projects = [
  { id: '1', name: 'Summer Vlog 2026', duration: 184, thumbnail: null, updatedAt: '2 hours ago' },
  { id: '2', name: 'Product Launch Reel', duration: 32, thumbnail: null, updatedAt: 'Yesterday' },
  { id: '3', name: 'Tutorial - Getting Started', duration: 567, thumbnail: null, updatedAt: '3 days ago' },
]

export default function ProjectsPage() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-text">Projects</h1>
        <Button>
          <Plus className="w-4 h-4 mr-2" />
          New Project
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <button className="aspect-video rounded-xl border-2 border-dashed border-border hover:border-primary transition-colors flex flex-col items-center justify-center gap-2 text-text-muted hover:text-primary">
          <Plus className="w-8 h-8" />
          <span className="text-sm font-medium">Create New Project</span>
        </button>

        {projects.map((project) => (
          <div
            key={project.id}
            className="group aspect-video rounded-xl bg-surface border border-border overflow-hidden hover:border-border-light transition-all"
          >
            <div className="relative h-full w-full bg-surface-hover flex items-center justify-center">
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-12 h-12 rounded-full bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <Play className="w-5 h-5 text-white ml-0.5" />
                </div>
              </div>
              <span className="text-text-muted text-sm">No Thumbnail</span>
              <span className="absolute bottom-2 right-2 text-xs bg-black/70 text-text px-1.5 py-0.5 rounded">
                {formatDuration(project.duration)}
              </span>
            </div>
            <div className="p-3 flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-text truncate">{project.name}</p>
                <p className="text-xs text-text-muted">{project.updatedAt}</p>
              </div>
              <button className="p-1 rounded hover:bg-surface-hover opacity-0 group-hover:opacity-100">
                <MoreHorizontal className="w-4 h-4 text-text-secondary" />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
