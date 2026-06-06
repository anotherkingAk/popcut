'use client'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

export class AdminAPIClientError extends Error {
  constructor(
    message: string,
    public status: number,
    public code: string = 'UNKNOWN_ERROR',
  ) {
    super(message)
    this.name = 'AdminAPIClientError'
  }
}

export class AdminAPIClient {
  private token: string | null = null

  constructor() {
    if (typeof window !== 'undefined') {
      this.token = localStorage.getItem('admin_token')
    }
  }

  setToken(token: string | null) {
    this.token = token
    if (token) {
      localStorage.setItem('admin_token', token)
    } else {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_user')
    }
  }

  isAuthenticated(): boolean {
    return !!this.token
  }

  private async request<T>(
    method: string,
    path: string,
    body?: unknown,
    opts?: { formData?: boolean },
  ): Promise<T> {
    const headers: Record<string, string> = {}
    if (!opts?.formData) {
      headers['Content-Type'] = 'application/json'
    }
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`
    }

    const res = await fetch(`${API_URL}/api/v1${path}`, {
      method,
      headers,
      body: opts?.formData ? (body as FormData) : body ? JSON.stringify(body) : undefined,
    })

    if (!res.ok) {
      if (res.status === 401) {
        this.setToken(null)
        if (typeof window !== 'undefined') {
          window.location.href = '/admin/login'
        }
      }
      const err = await res.json().catch(() => ({ message: res.statusText }))
      throw new AdminAPIClientError(
        err.message || `Request failed with status ${res.status}`,
        res.status,
        err.code,
      )
    }

    if (res.status === 204 || res.headers.get('content-length') === '0') {
      return undefined as T
    }

    return res.json() as Promise<T>
  }

  // ─── Auth ───────────────────────────────────────────────

  async login(email: string, password: string) {
    const data = await this.request<{ accessToken: string; refreshToken: string }>(
      'POST',
      '/auth/login',
      { email, password },
    )
    this.setToken(data.accessToken)
    return data
  }

  async getProfile() {
    return this.request<{
      id: string
      email: string
      name: string | null
      avatar: string | null
      role: string
      isActive: boolean
      credits: number
      createdAt: string
      updatedAt: string
    }>('GET', '/auth/me')
  }

  async logout() {
    await this.request<void>('POST', '/auth/logout')
    this.setToken(null)
  }

  // ─── Dashboard ──────────────────────────────────────────

  async getDashboard() {
    return this.request<{
      users: number
      projects: number
      templates: number
      effects: number
      activeJobs: number
      revenue: number
      recentUsers: Array<{ id: string; email: string; name: string | null; createdAt: string }>
    }>('GET', '/admin/dashboard')
  }

  // ─── Users ──────────────────────────────────────────────

  async getUsers(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/users?page=${page}&limit=${limit}`,
    )
  }

  async getUser(id: string) {
    return this.request<unknown>('GET', `/admin/users/${id}`)
  }

  async updateUser(id: string, data: Record<string, unknown>) {
    return this.request<unknown>('PUT', `/admin/users/${id}`, data)
  }

  async deleteUser(id: string) {
    return this.request<void>('DELETE', `/admin/users/${id}`)
  }

  // ─── Projects ───────────────────────────────────────────

  async getProjects(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/projects?page=${page}&limit=${limit}`,
    )
  }

  async deleteProject(id: string) {
    return this.request<void>('DELETE', `/admin/projects/${id}`)
  }

  // ─── Content (Templates, Effects, Filters, Fonts, Audio) ─

  async getTemplates(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/templates?page=${page}&limit=${limit}`,
    )
  }

  async createTemplate(data: Record<string, unknown>) {
    return this.request<unknown>('POST', '/admin/templates', data)
  }

  async updateTemplate(id: string, data: Record<string, unknown>) {
    return this.request<unknown>('PUT', `/admin/templates/${id}`, data)
  }

  async deleteTemplate(id: string) {
    return this.request<void>('DELETE', `/admin/templates/${id}`)
  }

  async getEffects(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/effects?page=${page}&limit=${limit}`,
    )
  }

  async createEffect(data: Record<string, unknown>) {
    return this.request<unknown>('POST', '/admin/effects', data)
  }

  async updateEffect(id: string, data: Record<string, unknown>) {
    return this.request<unknown>('PUT', `/admin/effects/${id}`, data)
  }

  async deleteEffect(id: string) {
    return this.request<void>('DELETE', `/admin/effects/${id}`)
  }

  async getFilters(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/filters?page=${page}&limit=${limit}`,
    )
  }

  async createFilter(data: Record<string, unknown>) {
    return this.request<unknown>('POST', '/admin/filters', data)
  }

  async updateFilter(id: string, data: Record<string, unknown>) {
    return this.request<unknown>('PUT', `/admin/filters/${id}`, data)
  }

  async deleteFilter(id: string) {
    return this.request<void>('DELETE', `/admin/filters/${id}`)
  }

  async getFonts(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/fonts?page=${page}&limit=${limit}`,
    )
  }

  async createFont(data: Record<string, unknown>) {
    return this.request<unknown>('POST', '/admin/fonts', data)
  }

  async updateFont(id: string, data: Record<string, unknown>) {
    return this.request<unknown>('PUT', `/admin/fonts/${id}`, data)
  }

  async deleteFont(id: string) {
    return this.request<void>('DELETE', `/admin/fonts/${id}`)
  }

  async getAudio(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/audio?page=${page}&limit=${limit}`,
    )
  }

  async createAudio(data: Record<string, unknown>) {
    return this.request<unknown>('POST', '/admin/audio', data)
  }

  async updateAudio(id: string, data: Record<string, unknown>) {
    return this.request<unknown>('PUT', `/admin/audio/${id}`, data)
  }

  async deleteAudio(id: string) {
    return this.request<void>('DELETE', `/admin/audio/${id}`)
  }

  // ─── Subscriptions ──────────────────────────────────────

  async getSubscriptions(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/subscriptions?page=${page}&limit=${limit}`,
    )
  }

  async updateSubscription(id: string, data: Record<string, unknown>) {
    return this.request<unknown>('PUT', `/admin/subscriptions/${id}`, data)
  }

  // ─── AI Jobs ────────────────────────────────────────────

  async getAIJobs(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/ai-jobs?page=${page}&limit=${limit}`,
    )
  }

  async retryAIJob(id: string) {
    return this.request<unknown>('POST', `/admin/ai-jobs/${id}/retry`)
  }

  // ─── Export Jobs ────────────────────────────────────────

  async getExportJobs(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/export-jobs?page=${page}&limit=${limit}`,
    )
  }

  // ─── Audit Logs ─────────────────────────────────────────

  async getAuditLogs(page = 1, limit = 50) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/audit-logs?page=${page}&limit=${limit}`,
    )
  }

  // ─── Feature Flags ──────────────────────────────────────

  async getFeatureFlags() {
    return this.request<unknown[]>('GET', '/admin/feature-flags')
  }

  async createFeatureFlag(data: Record<string, unknown>) {
    return this.request<unknown>('POST', '/admin/feature-flags', data)
  }

  async updateFeatureFlag(id: string, data: Record<string, unknown>) {
    return this.request<unknown>('PUT', `/admin/feature-flags/${id}`, data)
  }

  async deleteFeatureFlag(id: string) {
    return this.request<void>('DELETE', `/admin/feature-flags/${id}`)
  }

  // ─── Credit Transactions ────────────────────────────────

  async getCreditTransactions(page = 1, limit = 20) {
    return this.request<{ data: unknown[]; total: number; page: number; limit: number; totalPages: number }>(
      'GET',
      `/admin/credit-transactions?page=${page}&limit=${limit}`,
    )
  }

  async createCreditTransaction(data: { userId: string; amount: number; type: string; description?: string }) {
    return this.request<unknown>('POST', '/admin/credit-transactions', data)
  }

  // ─── Settings ───────────────────────────────────────────

  async getMaintenanceMode() {
    return this.request<{ enabled: boolean; message?: string }>('GET', '/admin/settings/maintenance')
  }

  async setMaintenanceMode(enabled: boolean, message?: string) {
    return this.request<unknown>('PUT', '/admin/settings/maintenance', { enabled, message })
  }

  async triggerBackup() {
    return this.request<{ message: string; timestamp: string }>('POST', '/admin/settings/backup')
  }

  async getBackupStatus() {
    return this.request<{ status: string; lastBackup: string | null; message: string }>('GET', '/admin/settings/backup/status')
  }

  // ─── Asset Upload ───────────────────────────────────────

  async uploadAsset(file: File) {
    const formData = new FormData()
    formData.append('file', file)
    return this.request<{ url: string }>('POST', '/admin/assets/upload', formData, { formData: true })
  }
}

export const adminClient = new AdminAPIClient()
