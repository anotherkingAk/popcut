import { useQuery } from '@tanstack/react-query'
import { adminApi } from '@/lib/admin-api'

export function useDashboardMetrics() {
  return useQuery({
    queryKey: ['admin', 'dashboard'],
    queryFn: () => adminApi.getDashboardMetrics(),
  })
}

export function useAnalyticsData(period = '30d') {
  return useQuery({
    queryKey: ['admin', 'analytics', period],
    queryFn: () => adminApi.getAnalyticsData(period),
  })
}
