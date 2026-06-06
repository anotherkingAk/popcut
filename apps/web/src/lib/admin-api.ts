'use client'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

class AdminApiError extends Error {
  status: number
  code: string
  constructor(message: string, status: number, code = 'UNKNOWN_ERROR') {
    super(message)
    this.name = 'AdminApiError'
    this.status = status
    this.code = code
  }
}

function getToken(): string | null {
  if (typeof window === 'undefined') return null
  return localStorage.getItem('admin_token')
}

export function getStoredUser<T = unknown>(): T | null {
  if (typeof window === 'undefined') return null
  const raw = localStorage.getItem('admin_user')
  return raw ? (JSON.parse(raw) as T) : null
}

async function request<T>(method: string, path: string, body?: unknown, opts?: { noAuth?: boolean }): Promise<T> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  if (!opts?.noAuth) {
    const token = getToken()
    if (token) headers.Authorization = `Bearer ${token}`
  }

  const res = await fetch(`${API_URL}/api/v1${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  })

  if (!res.ok) {
    if (res.status === 401) {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_user')
      if (typeof window !== 'undefined') {
        window.location.href = '/admin/login'
      }
    }
    const err = await res.json().catch(() => ({ message: res.statusText }))
    throw new AdminApiError(
      err.message || `Request failed with status ${res.status}`,
      res.status,
      err.code,
    )
  }

  if (res.status === 204) return undefined as T
  return res.json() as Promise<T>
}

function paginated<T>(method: string, path: string, page: number, limit: number, body?: unknown) {
  const query = `?page=${page}&limit=${limit}`
  if (body) return request<{ data: T[]; total: number; page: number; limit: number; totalPages: number }>(method, `${path}${query}`, body)
  return request<{ data: T[]; total: number; page: number; limit: number; totalPages: number }>(method, `${path}${query}`)
}

interface LoginResponse {
  accessToken: string
  refreshToken: string
}

interface MeResponse {
  id: string
  email: string
  name?: string
  avatar?: string
  role?: string
  isActive?: boolean
  credits?: number
  createdAt?: string
  updatedAt?: string
}

export const adminApi = {
  login: async (email: string, password: string) => {
    const tokens = await request<LoginResponse>('POST', '/auth/login', { email, password }, { noAuth: true })
    localStorage.setItem('admin_token', tokens.accessToken)
    const user = await request<MeResponse>('GET', '/auth/me')
    const mapped = {
      id: user.id,
      email: user.email,
      name: user.name || null,
      avatar: user.avatar || null,
      role: (user.role || 'admin').toLowerCase() as 'owner' | 'admin' | 'moderator' | 'support',
      status: (user.isActive !== false ? 'active' : 'suspended') as 'active' | 'suspended',
      credits: user.credits ?? 0,
      subscriptionTier: null,
      projectsCount: 0,
      totalExports: 0,
      storageUsed: 0,
      createdAt: user.createdAt || new Date().toISOString(),
      updatedAt: user.updatedAt || new Date().toISOString(),
    }
    localStorage.setItem('admin_user', JSON.stringify(mapped))
    return { token: tokens.accessToken, user: mapped }
  },

  getMe: async () => {
    const user = await request<MeResponse>('GET', '/auth/me')
    return {
      id: user.id,
      email: user.email,
      name: user.name || null,
      avatar: user.avatar || null,
      role: (user.role || 'admin').toLowerCase() as 'owner' | 'admin' | 'moderator' | 'support',
      status: (user.isActive !== false ? 'active' : 'suspended') as 'active' | 'suspended',
      credits: user.credits ?? 0,
      subscriptionTier: null,
      projectsCount: 0,
      totalExports: 0,
      storageUsed: 0,
      createdAt: user.createdAt || new Date().toISOString(),
      updatedAt: user.updatedAt || new Date().toISOString(),
    }
  },

  getDashboardMetrics: () =>
    request<{
      dau: number; mau: number; revenue: number; revenueChange: number
      activeExports: number; aiUsage: number; storageUsed: number
      totalUsers: number; newUsersToday: number; totalProjects: number
    }>('GET', '/admin/dashboard'),

  getAnalyticsData: (period = '30d') =>
    request<{
      dailyActiveUsers: { date: string; value: number }[]
      revenue: { date: string; value: number }[]
      userGrowth: { date: string; value: number }[]
      exports: { date: string; value: number }[]
      aiUsage: { date: string; value: number }[]
      storage: { date: string; value: number }[]
    }>('GET', `/admin/analytics?period=${period}`),

  getUsers: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').AdminUser>('GET', '/admin/users', page, limit),

  getUser: (id: string) =>
    request<import('@/types/admin').AdminUser>('GET', `/admin/users/${id}`),

  updateUser: (id: string, data: Partial<import('@/types/admin').AdminUser>) =>
    request<import('@/types/admin').AdminUser>('PUT', `/admin/users/${id}`, data),

  deleteUser: (id: string) =>
    request<void>('DELETE', `/admin/users/${id}`),

  suspendUser: (id: string) =>
    request<void>('PUT', `/admin/users/${id}/suspend`),

  unsuspendUser: (id: string) =>
    request<void>('PUT', `/admin/users/${id}/unsuspend`),

  assignCredits: (userId: string, amount: number) =>
    request<void>('POST', `/admin/users/${userId}/credits`, { amount }),

  getUserExports: (userId: string) =>
    request<import('@/types/admin').ExportRecord[]>('GET', `/admin/users/${userId}/exports`),

  getProjects: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').Project>('GET', '/admin/projects', page, limit),

  deleteProject: (id: string) =>
    request<void>('DELETE', `/admin/projects/${id}`),

  getTemplates: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').Template>('GET', '/admin/templates', page, limit),

  getTemplate: (id: string) =>
    request<import('@/types/admin').Template>('GET', `/admin/templates/${id}`),

  createTemplate: (data: Partial<import('@/types/admin').Template>) =>
    request<import('@/types/admin').Template>('POST', '/admin/templates', data),

  updateTemplate: (id: string, data: Partial<import('@/types/admin').Template>) =>
    request<import('@/types/admin').Template>('PUT', `/admin/templates/${id}`, data),

  deleteTemplate: (id: string) =>
    request<void>('DELETE', `/admin/templates/${id}`),

  publishTemplate: (id: string) =>
    request<void>('POST', `/admin/templates/${id}/publish`),

  unpublishTemplate: (id: string) =>
    request<void>('POST', `/admin/templates/${id}/unpublish`),

  getEffects: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').Effect>('GET', '/admin/effects', page, limit),

  getEffect: (id: string) =>
    request<import('@/types/admin').Effect>('GET', `/admin/effects/${id}`),

  createEffect: (data: Partial<import('@/types/admin').Effect>) =>
    request<import('@/types/admin').Effect>('POST', '/admin/effects', data),

  updateEffect: (id: string, data: Partial<import('@/types/admin').Effect>) =>
    request<import('@/types/admin').Effect>('PUT', `/admin/effects/${id}`, data),

  deleteEffect: (id: string) =>
    request<void>('DELETE', `/admin/effects/${id}`),

  publishEffect: (id: string) =>
    request<void>('POST', `/admin/effects/${id}/publish`),

  unpublishEffect: (id: string) =>
    request<void>('POST', `/admin/effects/${id}/unpublish`),

  getFilters: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').Filter>('GET', '/admin/filters', page, limit),

  getFilter: (id: string) =>
    request<import('@/types/admin').Filter>('GET', `/admin/filters/${id}`),

  createFilter: (data: Partial<import('@/types/admin').Filter>) =>
    request<import('@/types/admin').Filter>('POST', '/admin/filters', data),

  updateFilter: (id: string, data: Partial<import('@/types/admin').Filter>) =>
    request<import('@/types/admin').Filter>('PUT', `/admin/filters/${id}`, data),

  deleteFilter: (id: string) =>
    request<void>('DELETE', `/admin/filters/${id}`),

  publishFilter: (id: string) =>
    request<void>('POST', `/admin/filters/${id}/publish`),

  unpublishFilter: (id: string) =>
    request<void>('POST', `/admin/filters/${id}/unpublish`),

  getFonts: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').Font>('GET', '/admin/fonts', page, limit),

  getFont: (id: string) =>
    request<import('@/types/admin').Font>('GET', `/admin/fonts/${id}`),

  createFont: (data: Partial<import('@/types/admin').Font>) =>
    request<import('@/types/admin').Font>('POST', '/admin/fonts', data),

  updateFont: (id: string, data: Partial<import('@/types/admin').Font>) =>
    request<import('@/types/admin').Font>('PUT', `/admin/fonts/${id}`, data),

  deleteFont: (id: string) =>
    request<void>('DELETE', `/admin/fonts/${id}`),

  publishFont: (id: string) =>
    request<void>('POST', `/admin/fonts/${id}/publish`),

  unpublishFont: (id: string) =>
    request<void>('POST', `/admin/fonts/${id}/unpublish`),

  getAudio: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').AudioTrack>('GET', '/admin/audio', page, limit),

  getAudioTrack: (id: string) =>
    request<import('@/types/admin').AudioTrack>('GET', `/admin/audio/${id}`),

  createAudio: (data: Partial<import('@/types/admin').AudioTrack>) =>
    request<import('@/types/admin').AudioTrack>('POST', '/admin/audio', data),

  updateAudio: (id: string, data: Partial<import('@/types/admin').AudioTrack>) =>
    request<import('@/types/admin').AudioTrack>('PUT', `/admin/audio/${id}`, data),

  deleteAudio: (id: string) =>
    request<void>('DELETE', `/admin/audio/${id}`),

  publishAudio: (id: string) =>
    request<void>('POST', `/admin/audio/${id}/publish`),

  unpublishAudio: (id: string) =>
    request<void>('POST', `/admin/audio/${id}/unpublish`),

  getTransitions: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').Transition>('GET', '/admin/transitions', page, limit),

  getTransition: (id: string) =>
    request<import('@/types/admin').Transition>('GET', `/admin/transitions/${id}`),

  createTransition: (data: Partial<import('@/types/admin').Transition>) =>
    request<import('@/types/admin').Transition>('POST', '/admin/transitions', data),

  updateTransition: (id: string, data: Partial<import('@/types/admin').Transition>) =>
    request<import('@/types/admin').Transition>('PUT', `/admin/transitions/${id}`, data),

  deleteTransition: (id: string) =>
    request<void>('DELETE', `/admin/transitions/${id}`),

  publishTransition: (id: string) =>
    request<void>('POST', `/admin/transitions/${id}/publish`),

  unpublishTransition: (id: string) =>
    request<void>('POST', `/admin/transitions/${id}/unpublish`),

  getColorGrades: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').ColorGrade>('GET', '/admin/color-grades', page, limit),

  getColorGrade: (id: string) =>
    request<import('@/types/admin').ColorGrade>('GET', `/admin/color-grades/${id}`),

  createColorGrade: (data: Partial<import('@/types/admin').ColorGrade>) =>
    request<import('@/types/admin').ColorGrade>('POST', '/admin/color-grades', data),

  updateColorGrade: (id: string, data: Partial<import('@/types/admin').ColorGrade>) =>
    request<import('@/types/admin').ColorGrade>('PUT', `/admin/color-grades/${id}`, data),

  deleteColorGrade: (id: string) =>
    request<void>('DELETE', `/admin/color-grades/${id}`),

  publishColorGrade: (id: string) =>
    request<void>('POST', `/admin/color-grades/${id}/publish`),

  unpublishColorGrade: (id: string) =>
    request<void>('POST', `/admin/color-grades/${id}/unpublish`),

  getSubscriptions: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').Subscription>('GET', '/admin/subscriptions', page, limit),

  updateSubscription: (id: string, data: Partial<import('@/types/admin').Subscription>) =>
    request<import('@/types/admin').Subscription>('PUT', `/admin/subscriptions/${id}`, data),

  cancelSubscription: (id: string) =>
    request<void>('POST', `/admin/subscriptions/${id}/cancel`),

  getCreditPackages: () =>
    request<import('@/types/admin').CreditPackage[]>('GET', '/admin/credit-packages'),

  createCreditPackage: (data: Partial<import('@/types/admin').CreditPackage>) =>
    request<import('@/types/admin').CreditPackage>('POST', '/admin/credit-packages', data),

  updateCreditPackage: (id: string, data: Partial<import('@/types/admin').CreditPackage>) =>
    request<import('@/types/admin').CreditPackage>('PUT', `/admin/credit-packages/${id}`, data),

  togglePackageActive: (id: string) =>
    request<void>('PATCH', `/admin/credit-packages/${id}/toggle`),

  getCreditTransactions: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').CreditTransaction>('GET', '/admin/credit-transactions', page, limit),

  getAIGenerationJobs: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').AIGenerationJob>('GET', '/admin/ai-jobs', page, limit),

  submitAIGeneration: (type: string, input: Record<string, unknown>) =>
    request<import('@/types/admin').AIGenerationJob>('POST', '/admin/ai-jobs', { type, input }),

  reviewAIGeneration: (id: string, approved: boolean) =>
    request<void>('POST', `/admin/ai-jobs/${id}/review`, { approved }),

  getAuditLogs: (page = 1, limit = 20) =>
    paginated<import('@/types/admin').AuditLog>('GET', '/admin/audit-logs', page, limit),

  getFeatureFlags: () =>
    request<import('@/types/admin').FeatureFlag[]>('GET', '/admin/feature-flags'),

  createFeatureFlag: (data: Partial<import('@/types/admin').FeatureFlag>) =>
    request<import('@/types/admin').FeatureFlag>('POST', '/admin/feature-flags', data),

  updateFeatureFlag: (id: string, data: Partial<import('@/types/admin').FeatureFlag>) =>
    request<import('@/types/admin').FeatureFlag>('PUT', `/admin/feature-flags/${id}`, data),

  toggleFeatureFlag: (id: string) =>
    request<void>('PATCH', `/admin/feature-flags/${id}/toggle`),

  getAppSettings: () =>
    request<import('@/types/admin').AppSettings>('GET', '/admin/settings'),

  updateAppSettings: (data: Partial<import('@/types/admin').AppSettings>) =>
    request<import('@/types/admin').AppSettings>('PUT', '/admin/settings', data),

  uploadAsset: async (file: File) => {
    const token = getToken()
    const formData = new FormData()
    formData.append('file', file)
    const headers: Record<string, string> = {}
    if (token) headers.Authorization = `Bearer ${token}`
    const res = await fetch(`${API_URL}/api/v1/admin/assets/upload`, {
      method: 'POST',
      headers,
      body: formData,
    })
    if (!res.ok) throw new AdminApiError('Upload failed', res.status)
    return res.json() as Promise<{ url: string }>
  },
}
