'use client'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

class AdminAPI {
  private token: string | null = null

  setToken(token: string) { this.token = token }
  clearToken() { this.token = null }
  isAuthenticated() { return !!this.token }

  private async request<T>(method: string, path: string, body?: unknown): Promise<T> {
    const res = await fetch(`${API_URL}/api/v1${path}`, {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(this.token ? { Authorization: `Bearer ${this.token}` } : {}),
      },
      body: body ? JSON.stringify(body) : undefined,
    })
    if (!res.ok) {
      const err = await res.json().catch(() => ({ message: 'Request failed' }))
      throw new Error(err.message || `HTTP ${res.status}`)
    }
    return res.json()
  }

  // Auth
  login(email: string, password: string) {
    return this.request<{ accessToken: string }>('POST', '/auth/login', { email, password })
  }

  // Dashboard
  getDashboard() { return this.request<Dashboard>('GET', '/admin/dashboard') }

  // Users
  getUsers(page = 1, limit = 20) { return this.request<Paginated<User>>('GET', `/admin/users?page=${page}&limit=${limit}`) }
  getUser(id: string) { return this.request<User>('GET', `/admin/users/${id}`) }
  updateUser(id: string, data: Partial<User>) { return this.request<User>('PUT', `/admin/users/${id}`, data) }
  deleteUser(id: string) { return this.request<{ message: string }>('DELETE', `/admin/users/${id}`) }

  // Projects
  getProjects(page = 1, limit = 20) { return this.request<Paginated<Project>>('GET', `/admin/projects?page=${page}&limit=${limit}`) }
  deleteProject(id: string) { return this.request<{ message: string }>('DELETE', `/admin/projects/${id}`) }

  // Templates
  getTemplates(page = 1, limit = 20) { return this.request<Paginated<Template>>('GET', `/admin/templates?page=${page}&limit=${limit}`) }
  createTemplate(data: any) { return this.request<Template>('POST', '/admin/templates', data) }
  updateTemplate(id: string, data: any) { return this.request<Template>('PUT', `/admin/templates/${id}`, data) }
  deleteTemplate(id: string) { return this.request<{ message: string }>('DELETE', `/admin/templates/${id}`) }

  // Effects
  getEffects(page = 1, limit = 20) { return this.request<Paginated<Effect>>('GET', `/admin/effects?page=${page}&limit=${limit}`) }
  createEffect(data: any) { return this.request<Effect>('POST', '/admin/effects', data) }
  updateEffect(id: string, data: any) { return this.request<Effect>('PUT', `/admin/effects/${id}`, data) }
  deleteEffect(id: string) { return this.request<{ message: string }>('DELETE', `/admin/effects/${id}`) }

  // Filters
  getFilters(page = 1, limit = 20) { return this.request<Paginated<Filter>>('GET', `/admin/filters?page=${page}&limit=${limit}`) }
  createFilter(data: any) { return this.request<Filter>('POST', '/admin/filters', data) }
  updateFilter(id: string, data: any) { return this.request<Filter>('PUT', `/admin/filters/${id}`, data) }
  deleteFilter(id: string) { return this.request<{ message: string }>('DELETE', `/admin/filters/${id}`) }

  // Fonts
  getFonts(page = 1, limit = 20) { return this.request<Paginated<Font>>('GET', `/admin/fonts?page=${page}&limit=${limit}`) }
  createFont(data: any) { return this.request<Font>('POST', '/admin/fonts', data) }
  updateFont(id: string, data: any) { return this.request<Font>('PUT', `/admin/fonts/${id}`, data) }
  deleteFont(id: string) { return this.request<{ message: string }>('DELETE', `/admin/fonts/${id}`) }

  // Audio
  getAudio(page = 1, limit = 20) { return this.request<Paginated<AudioItem>>('GET', `/admin/audio?page=${page}&limit=${limit}`) }
  createAudio(data: any) { return this.request<AudioItem>('POST', '/admin/audio', data) }
  updateAudio(id: string, data: any) { return this.request<AudioItem>('PUT', `/admin/audio/${id}`, data) }
  deleteAudio(id: string) { return this.request<{ message: string }>('DELETE', `/admin/audio/${id}`) }

  // Subscriptions
  getSubscriptions(page = 1, limit = 20) { return this.request<Paginated<Subscription>>('GET', `/admin/subscriptions?page=${page}&limit=${limit}`) }
  updateSubscription(id: string, data: any) { return this.request<Subscription>('PUT', `/admin/subscriptions/${id}`, data) }

  // AI Jobs
  getAIJobs(page = 1, limit = 20) { return this.request<Paginated<AIJob>>('GET', `/admin/ai-jobs?page=${page}&limit=${limit}`) }
  retryAIJob(id: string) { return this.request<AIJob>('POST', `/admin/ai-jobs/${id}/retry`) }

  // Export Jobs
  getExportJobs(page = 1, limit = 20) { return this.request<Paginated<ExportJob>>('GET', `/admin/export-jobs?page=${page}&limit=${limit}`) }

  // Audit Logs
  getAuditLogs(page = 1, limit = 50) { return this.request<Paginated<AuditLog>>('GET', `/admin/audit-logs?page=${page}&limit=${limit}`) }

  // Feature Flags
  getFeatureFlags() { return this.request<FeatureFlag[]>('GET', '/admin/feature-flags') }
  createFeatureFlag(data: any) { return this.request<FeatureFlag>('POST', '/admin/feature-flags', data) }
  updateFeatureFlag(id: string, data: any) { return this.request<FeatureFlag>('PUT', `/admin/feature-flags/${id}`, data) }
  deleteFeatureFlag(id: string) { return this.request<{ message: string }>('DELETE', `/admin/feature-flags/${id}`) }

  // Credit Transactions
  getCreditTxns(page = 1, limit = 20) { return this.request<Paginated<CreditTxn>>('GET', `/admin/credit-transactions?page=${page}&limit=${limit}`) }
  createCreditTxn(data: any) { return this.request<CreditTxn>('POST', '/admin/credit-transactions', data) }
}

export const api = new AdminAPI()

// Types
export interface Dashboard {
  users: number; projects: number; templates: number; effects: number
  activeJobs: number; revenue: number; recentUsers: User[]
}
export interface User { id: string; email: string; name?: string; role: string; avatar?: string; credits: number; isActive: boolean; createdAt: string; updatedAt: string }
export interface Project { id: string; name: string; userId: string; user?: { id: string; email: string; name?: string }; status: string; duration: number; createdAt: string; updatedAt: string }
export interface Template { id: string; name: string; description?: string; category: string; isPublic: boolean; isPremium: boolean; usageCount: number; createdAt: string }
export interface Effect { id: string; name: string; description?: string; type: string; category: string; isPublic: boolean; isPremium: boolean; createdAt: string }
export interface Filter { id: string; name: string; description?: string; category: string; isPublic: boolean; isPremium: boolean; createdAt: string }
export interface Font { id: string; name: string; family: string; category: string; isPublic: boolean; isPremium: boolean; formats: string[]; createdAt: string }
export interface AudioItem { id: string; name: string; duration: number; category: string; isPublic: boolean; isPremium: boolean; mood?: string; createdAt: string }
export interface Subscription { id: string; userId: string; user?: { id: string; email: string; name?: string }; plan: string; status: string; price: number; startDate: string; endDate?: string; autoRenew: boolean }
export interface AIJob { id: string; userId: string; user?: { id: string; email: string; name?: string }; type: string; status: string; progress: number; error?: string; createdAt: string }
export interface ExportJob { id: string; userId: string; user?: { id: string; email: string; name?: string }; projectId: string; project?: { id: string; name: string }; format: string; quality: string; status: string; progress: number; createdAt: string }
export interface AuditLog { id: string; userId: string; user?: { id: string; email: string; name?: string }; action: string; entity?: string; entityId?: string; ip?: string; createdAt: string }
export interface FeatureFlag { id: string; name: string; enabled: boolean; description?: string; rules?: any; createdAt: string; updatedAt: string }
export interface CreditTxn { id: string; userId: string; user?: { id: string; email: string; name?: string }; amount: number; type: string; description?: string; createdAt: string }
export interface Paginated<T> { data: T[]; total: number; page: number; limit: number; totalPages: number }
