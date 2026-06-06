import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/lib/admin-api'
import { toast } from 'sonner'

export function useUsers(page = 1, limit = 20) {
  return useQuery({
    queryKey: ['admin', 'users', page, limit],
    queryFn: () => adminApi.getUsers(page, limit),
  })
}

export function useUser(id: string) {
  return useQuery({
    queryKey: ['admin', 'users', id],
    queryFn: () => adminApi.getUser(id),
    enabled: !!id,
  })
}

export function useUserExports(userId: string) {
  return useQuery({
    queryKey: ['admin', 'users', userId, 'exports'],
    queryFn: () => adminApi.getUserExports(userId),
    enabled: !!userId,
  })
}

export function useDeleteUser() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => adminApi.deleteUser(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'users'] })
      toast.success('User deleted')
    },
  })
}

export function useSuspendUser() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => adminApi.suspendUser(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'users'] })
      toast.success('User suspended')
    },
  })
}

export function useUnsuspendUser() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => adminApi.unsuspendUser(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'users'] })
      toast.success('User reinstated')
    },
  })
}

export function useAssignCredits() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ userId, amount }: { userId: string; amount: number }) =>
      adminApi.assignCredits(userId, amount),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'users'] })
      toast.success('Credits assigned')
    },
  })
}
