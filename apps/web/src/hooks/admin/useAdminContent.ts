import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/lib/admin-api'
import { toast } from 'sonner'

type ContentType = 'templates' | 'effects' | 'filters' | 'fonts' | 'audio' | 'transitions' | 'color-grades'

function contentKey(type: ContentType) {
  const map: Record<ContentType, string> = {
    templates: 'templates', effects: 'effects', filters: 'filters',
    fonts: 'fonts', audio: 'audio', transitions: 'transitions',
    'color-grades': 'color-grades',
  }
  return map[type]
}

export function useContentList(type: ContentType, page = 1, limit = 20) {
  return useQuery({
    queryKey: ['admin', contentKey(type), page, limit],
    queryFn: async () => {
      const res = await (async () => {
        switch (type) {
          case 'templates': return adminApi.getTemplates(page, limit)
          case 'effects': return adminApi.getEffects(page, limit)
          case 'filters': return adminApi.getFilters(page, limit)
          case 'fonts': return adminApi.getFonts(page, limit)
          case 'audio': return adminApi.getAudio(page, limit)
          case 'transitions': return adminApi.getTransitions(page, limit)
          case 'color-grades': return adminApi.getColorGrades(page, limit)
        }
      })()
      return res as unknown as { data: Record<string, unknown>[]; total: number; page: number; limit: number; totalPages: number }
    },
  })
}

export function useContentItem(type: ContentType, id: string) {
  return useQuery({
    queryKey: ['admin', contentKey(type), id],
    queryFn: async () => {
      const res = await (async () => {
        switch (type) {
          case 'templates': return adminApi.getTemplate(id)
          case 'effects': return adminApi.getEffect(id)
          case 'filters': return adminApi.getFilter(id)
          case 'fonts': return adminApi.getFont(id)
          case 'audio': return adminApi.getAudioTrack(id)
          case 'transitions': return adminApi.getTransition(id)
          case 'color-grades': return adminApi.getColorGrade(id)
        }
      })()
      return res as unknown as Record<string, unknown>
    },
    enabled: !!id,
  })
}

export function useCreateContent(type: ContentType) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: Record<string, unknown>) => {
      switch (type) {
        case 'templates': return adminApi.createTemplate(data as never) as unknown as void
        case 'effects': return adminApi.createEffect(data as never) as unknown as void
        case 'filters': return adminApi.createFilter(data as never) as unknown as void
        case 'fonts': return adminApi.createFont(data as never) as unknown as void
        case 'audio': return adminApi.createAudio(data as never) as unknown as void
        case 'transitions': return adminApi.createTransition(data as never) as unknown as void
        case 'color-grades': return adminApi.createColorGrade(data as never) as unknown as void
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', contentKey(type)] })
      toast.success('Content created')
    },
  })
}

export function useUpdateContent(type: ContentType) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Record<string, unknown> }) => {
      switch (type) {
        case 'templates': return adminApi.updateTemplate(id, data as never) as unknown as void
        case 'effects': return adminApi.updateEffect(id, data as never) as unknown as void
        case 'filters': return adminApi.updateFilter(id, data as never) as unknown as void
        case 'fonts': return adminApi.updateFont(id, data as never) as unknown as void
        case 'audio': return adminApi.updateAudio(id, data as never) as unknown as void
        case 'transitions': return adminApi.updateTransition(id, data as never) as unknown as void
        case 'color-grades': return adminApi.updateColorGrade(id, data as never) as unknown as void
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', contentKey(type)] })
      toast.success('Content updated')
    },
  })
}

export function useDeleteContent(type: ContentType) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      switch (type) {
        case 'templates': return adminApi.deleteTemplate(id) as unknown as void
        case 'effects': return adminApi.deleteEffect(id) as unknown as void
        case 'filters': return adminApi.deleteFilter(id) as unknown as void
        case 'fonts': return adminApi.deleteFont(id) as unknown as void
        case 'audio': return adminApi.deleteAudio(id) as unknown as void
        case 'transitions': return adminApi.deleteTransition(id) as unknown as void
        case 'color-grades': return adminApi.deleteColorGrade(id) as unknown as void
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', contentKey(type)] })
      toast.success('Content deleted')
    },
  })
}

export function usePublishContent(type: ContentType) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      switch (type) {
        case 'templates': return adminApi.publishTemplate(id) as unknown as void
        case 'effects': return adminApi.publishEffect(id) as unknown as void
        case 'filters': return adminApi.publishFilter(id) as unknown as void
        case 'fonts': return adminApi.publishFont(id) as unknown as void
        case 'audio': return adminApi.publishAudio(id) as unknown as void
        case 'transitions': return adminApi.publishTransition(id) as unknown as void
        case 'color-grades': return adminApi.publishColorGrade(id) as unknown as void
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', contentKey(type)] })
      toast.success('Content published')
    },
  })
}

export function useUnpublishContent(type: ContentType) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      switch (type) {
        case 'templates': return adminApi.unpublishTemplate(id) as unknown as void
        case 'effects': return adminApi.unpublishEffect(id) as unknown as void
        case 'filters': return adminApi.unpublishFilter(id) as unknown as void
        case 'fonts': return adminApi.unpublishFont(id) as unknown as void
        case 'audio': return adminApi.unpublishAudio(id) as unknown as void
        case 'transitions': return adminApi.unpublishTransition(id) as unknown as void
        case 'color-grades': return adminApi.unpublishColorGrade(id) as unknown as void
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', contentKey(type)] })
      toast.success('Content unpublished')
    },
  })
}
