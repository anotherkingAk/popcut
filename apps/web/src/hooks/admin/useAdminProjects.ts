import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '@/lib/admin-api'
import { toast } from 'sonner'

export function useProjects(page = 1, limit = 20) {
  return useQuery({
    queryKey: ['admin', 'projects', page, limit],
    queryFn: () => adminApi.getProjects(page, limit),
  })
}

export function useDeleteProject() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => adminApi.deleteProject(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'projects'] })
      toast.success('Project deleted')
    },
  })
}
