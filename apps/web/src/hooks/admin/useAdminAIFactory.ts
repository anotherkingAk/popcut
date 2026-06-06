import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/lib/admin-api'
import { toast } from 'sonner'

export function useAIGenerationJobs(page = 1, limit = 20) {
  return useQuery({
    queryKey: ['admin', 'ai-factory', page, limit],
    queryFn: () => adminApi.getAIGenerationJobs(page, limit),
  })
}

export function useSubmitAIGeneration() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ type, input }: { type: string; input: Record<string, unknown> }) =>
      adminApi.submitAIGeneration(type, input),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'ai-factory'] })
      toast.success('Generation job submitted')
    },
  })
}

export function useReviewAIGeneration() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, approved }: { id: string; approved: boolean }) =>
      adminApi.reviewAIGeneration(id, approved),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'ai-factory'] })
      toast.success('Review submitted')
    },
  })
}
