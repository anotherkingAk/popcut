import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/lib/admin-api'
import { toast } from 'sonner'

export function useAppSettings() {
  return useQuery({
    queryKey: ['admin', 'settings'],
    queryFn: () => adminApi.getAppSettings(),
  })
}

export function useUpdateAppSettings() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Record<string, unknown>) => adminApi.updateAppSettings(data as never),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'settings'] })
      toast.success('Settings updated')
    },
  })
}

export function useFeatureFlags() {
  return useQuery({
    queryKey: ['admin', 'feature-flags'],
    queryFn: () => adminApi.getFeatureFlags(),
  })
}

export function useCreateFeatureFlag() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Record<string, unknown>) => adminApi.createFeatureFlag(data as never),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'feature-flags'] })
      toast.success('Feature flag created')
    },
  })
}

export function useUpdateFeatureFlag() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Record<string, unknown> }) =>
      adminApi.updateFeatureFlag(id, data as never),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'feature-flags'] })
      toast.success('Feature flag updated')
    },
  })
}

export function useToggleFeatureFlag() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => adminApi.toggleFeatureFlag(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'feature-flags'] })
    },
  })
}
