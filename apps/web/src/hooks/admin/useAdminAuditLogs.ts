import { useQuery } from '@tanstack/react-query'
import { adminApi } from '@/lib/admin-api'

export function useAuditLogs(page = 1, limit = 20) {
  return useQuery({
    queryKey: ['admin', 'audit-logs', page, limit],
    queryFn: () => adminApi.getAuditLogs(page, limit),
  })
}
