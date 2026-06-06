'use client'

import { ContentList } from '@/components/admin/ContentList'

export default function ColorGradesPage() {
  return (
    <ContentList
      type="color-grades"
      title="Color Grades"
      description="Manage LUTs and color grading presets"
    />
  )
}
