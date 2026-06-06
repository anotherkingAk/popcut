import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/lib/admin-api'
import { toast } from 'sonner'

export function useSubscriptions(page = 1, limit = 20) {
  return useQuery({
    queryKey: ['admin', 'subscriptions', page, limit],
    queryFn: () => adminApi.getSubscriptions(page, limit),
  })
}

export function useUpdateSubscription() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Record<string, unknown> }) =>
      adminApi.updateSubscription(id, data as never),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'subscriptions'] })
      toast.success('Subscription updated')
    },
  })
}

export function useCancelSubscription() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => adminApi.cancelSubscription(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'subscriptions'] })
      toast.success('Subscription canceled')
    },
  })
}

export function useCreditPackages() {
  return useQuery({
    queryKey: ['admin', 'credit-packages'],
    queryFn: () => adminApi.getCreditPackages(),
  })
}

export function useCreateCreditPackage() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Record<string, unknown>) => adminApi.createCreditPackage(data as never),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'credit-packages'] })
      toast.success('Package created')
    },
  })
}

export function useUpdateCreditPackage() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Record<string, unknown> }) =>
      adminApi.updateCreditPackage(id, data as never),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'credit-packages'] })
      toast.success('Package updated')
    },
  })
}

export function useTogglePackageActive() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => adminApi.togglePackageActive(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'credit-packages'] })
    },
  })
}

export function useCreditTransactions(page = 1, limit = 20) {
  return useQuery({
    queryKey: ['admin', 'credit-transactions', page, limit],
    queryFn: () => adminApi.getCreditTransactions(page, limit),
  })
}
