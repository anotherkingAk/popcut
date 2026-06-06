'use client'

import { ContentList } from '@/components/admin/ContentList'

export default function FiltersPage() {
  return (
    <ContentList
      type="filters"
      title="Filters"
      description="Manage video filters"
    />
  )
}
