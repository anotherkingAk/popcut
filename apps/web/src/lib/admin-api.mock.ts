import type {
  AdminUser, Project, Template, Effect, Filter, Font, AudioTrack,
  Transition, ColorGrade, DashboardMetrics, AnalyticsData,
  Subscription, CreditPackage, CreditTransaction, AuditLog,
  FeatureFlag, AppSettings, AIGenerationJob, ContentStatus,
  SubscriptionStatus, ExportRecord, PaginatedResponse,
} from '@/types/admin'

const delay = (ms: number) => new Promise(r => setTimeout(r, ms))
async function mockRequest<T>(data: T, ms = 300): Promise<T> {
  await delay(ms)
  return data
}

function generateMockArray<T>(count: number, factory: (i: number) => T): T[] {
  return Array.from({ length: count }, (_, i) => factory(i))
}

const mockUser: AdminUser = {
  id: '1', email: 'admin@popcut.com', name: 'Admin User',
  avatar: null, role: 'owner', status: 'active', credits: 99999,
  subscriptionTier: 'enterprise', projectsCount: 0, totalExports: 0,
  storageUsed: 0, createdAt: '2024-01-01T00:00:00Z', updatedAt: '2025-01-01T00:00:00Z',
}

export const adminApi = {
  login: (email: string, password: string) =>
    mockRequest({ token: 'mock-jwt-token', user: mockUser }),

  getMe: () => mockRequest(mockUser),

  getDashboardMetrics: (): Promise<DashboardMetrics> =>
    mockRequest({
      dau: 12453, mau: 89234, revenue: 45230, revenueChange: 12.5,
      activeExports: 234, aiUsage: 1892, storageUsed: 2450,
      totalUsers: 125430, newUsersToday: 342, totalProjects: 45672,
    }),

  getAnalyticsData: (period = '30d'): Promise<AnalyticsData> => {
    const days = period === '7d' ? 7 : period === '90d' ? 90 : 30
    const data = Array.from({ length: days }, (_, i) => ({
      date: new Date(Date.now() - (days - i) * 86400000).toISOString().slice(0, 10),
      value: Math.floor(Math.random() * 1000) + 500,
    }))
    return mockRequest({
      dailyActiveUsers: data,
      revenue: data.map(d => ({ ...d, value: Math.floor(Math.random() * 5000) + 1000 })),
      userGrowth: data.map(d => ({ ...d, value: Math.floor(Math.random() * 200) + 50 })),
      exports: data.map(d => ({ ...d, value: Math.floor(Math.random() * 300) + 100 })),
      aiUsage: data.map(d => ({ ...d, value: Math.floor(Math.random() * 500) + 200 })),
      storage: data.map(d => ({ ...d, value: Math.floor(Math.random() * 100) + 10 })),
    })
  },

  getUsers: (page = 1, limit = 20): Promise<PaginatedResponse<AdminUser>> => {
    const users = generateMockArray(50, i => ({
      id: String(i + 1),
      email: `user${i + 1}@example.com`,
      name: i === 0 ? null : `User ${i + 1}`,
      avatar: null,
      role: (['owner', 'admin', 'moderator', 'support'] as const)[i % 4],
      status: i % 7 === 0 ? 'suspended' as const : 'active' as const,
      credits: Math.floor(Math.random() * 10000),
      subscriptionTier: [null, 'free', 'pro', 'business', 'enterprise'][i % 5],
      projectsCount: Math.floor(Math.random() * 50),
      totalExports: Math.floor(Math.random() * 200),
      storageUsed: Math.floor(Math.random() * 5000),
      createdAt: new Date(Date.now() - Math.random() * 365 * 86400000).toISOString(),
      updatedAt: new Date(Date.now() - Math.random() * 30 * 86400000).toISOString(),
    }))
    return mockRequest({
      data: users.slice((page - 1) * limit, page * limit),
      total: users.length, page, limit,
      totalPages: Math.ceil(users.length / limit),
    })
  },

  getUser: (id: string): Promise<AdminUser> => mockRequest({ ...mockUser, id }),
  updateUser: (id: string, data: Partial<AdminUser>): Promise<AdminUser> =>
    mockRequest({ ...mockUser, id, ...data }),
  deleteUser: (id: string): Promise<void> => mockRequest(undefined),
  suspendUser: (id: string): Promise<void> => mockRequest(undefined),
  unsuspendUser: (id: string): Promise<void> => mockRequest(undefined),
  assignCredits: (userId: string, amount: number): Promise<void> => mockRequest(undefined),

  getUserExports: (userId: string): Promise<ExportRecord[]> =>
    mockRequest(generateMockArray(10, i => ({
      id: String(i + 1), userId, userName: `User ${userId}`,
      projectId: String(Math.floor(Math.random() * 100)),
      projectName: `Project ${i + 1}`,
      format: ['mp4', 'mov', 'gif'][i % 3],
      resolution: ['720p', '1080p', '4k'][i % 3],
      duration: Math.floor(Math.random() * 300) + 10,
      fileSize: Math.floor(Math.random() * 500) + 50,
      status: (['completed', 'processing', 'failed', 'pending'] as const)[i % 4],
      progress: i % 4 === 1 ? Math.floor(Math.random() * 100) : 100,
      createdAt: new Date(Date.now() - Math.random() * 30 * 86400000).toISOString(),
      completedAt: i % 4 === 0 ? new Date(Date.now() - Math.random() * 30 * 86400000).toISOString() : null,
    }))),

  getProjects: (page = 1, limit = 20): Promise<PaginatedResponse<Project>> => {
    const projects = generateMockArray(50, i => ({
      id: String(i + 1), name: `Project ${i + 1}`,
      userId: String(Math.floor(Math.random() * 50) + 1),
      userName: `User ${Math.floor(Math.random() * 50) + 1}`,
      thumbnail: null, duration: Math.floor(Math.random() * 600) + 30,
      status: (['draft', 'processing', 'completed'] as const)[i % 3],
      templateId: i % 4 === 0 ? String(Math.floor(Math.random() * 20) + 1) : null,
      exportsCount: Math.floor(Math.random() * 20),
      createdAt: new Date(Date.now() - Math.random() * 90 * 86400000).toISOString(),
      updatedAt: new Date(Date.now() - Math.random() * 30 * 86400000).toISOString(),
    }))
    return mockRequest({
      data: projects.slice((page - 1) * limit, page * limit),
      total: projects.length, page, limit,
      totalPages: Math.ceil(projects.length / limit),
    })
  },

  deleteProject: (id: string): Promise<void> => mockRequest(undefined),

  getTemplates: (page = 1, limit = 20): Promise<PaginatedResponse<Template>> =>
    mockRequest(generatePaginatedContent<Template>('Template', page, limit)),
  getTemplate: (id: string): Promise<Template> => mockContentItem<Template>('Template', id),
  createTemplate: (data: Partial<Template>): Promise<Template> => mockRequest({ id: String(Date.now()), ...data } as Template),
  updateTemplate: (id: string, data: Partial<Template>): Promise<Template> =>
    mockRequest({ id, name: 'Updated Template', ...data } as Template),
  deleteTemplate: (id: string): Promise<void> => mockRequest(undefined),
  publishTemplate: (id: string): Promise<void> => mockRequest(undefined),
  unpublishTemplate: (id: string): Promise<void> => mockRequest(undefined),

  getEffects: (page = 1, limit = 20): Promise<PaginatedResponse<Effect>> =>
    mockRequest(generatePaginatedContent<Effect>('Effect', page, limit)),
  getEffect: (id: string): Promise<Effect> => mockContentItem<Effect>('Effect', id),
  createEffect: (data: Partial<Effect>): Promise<Effect> => mockRequest({ id: String(Date.now()), ...data } as Effect),
  updateEffect: (id: string, data: Partial<Effect>): Promise<Effect> =>
    mockRequest({ id, name: 'Updated Effect', ...data } as Effect),
  deleteEffect: (id: string): Promise<void> => mockRequest(undefined),
  publishEffect: (id: string): Promise<void> => mockRequest(undefined),
  unpublishEffect: (id: string): Promise<void> => mockRequest(undefined),

  getFilters: (page = 1, limit = 20): Promise<PaginatedResponse<Filter>> =>
    mockRequest(generatePaginatedContent<Filter>('Filter', page, limit)),
  getFilter: (id: string): Promise<Filter> => mockContentItem<Filter>('Filter', id),
  createFilter: (data: Partial<Filter>): Promise<Filter> => mockRequest({ id: String(Date.now()), ...data } as Filter),
  updateFilter: (id: string, data: Partial<Filter>): Promise<Filter> =>
    mockRequest({ id, name: 'Updated Filter', ...data } as Filter),
  deleteFilter: (id: string): Promise<void> => mockRequest(undefined),
  publishFilter: (id: string): Promise<void> => mockRequest(undefined),
  unpublishFilter: (id: string): Promise<void> => mockRequest(undefined),

  getFonts: (page = 1, limit = 20): Promise<PaginatedResponse<Font>> =>
    mockRequest(generatePaginatedContent<Font>('Font', page, limit)),
  getFont: (id: string): Promise<Font> => mockContentItem<Font>('Font', id),
  createFont: (data: Partial<Font>): Promise<Font> => mockRequest({ id: String(Date.now()), ...data } as Font),
  updateFont: (id: string, data: Partial<Font>): Promise<Font> =>
    mockRequest({ id, name: 'Updated Font', ...data } as Font),
  deleteFont: (id: string): Promise<void> => mockRequest(undefined),
  publishFont: (id: string): Promise<void> => mockRequest(undefined),
  unpublishFont: (id: string): Promise<void> => mockRequest(undefined),

  getAudio: (page = 1, limit = 20): Promise<PaginatedResponse<AudioTrack>> =>
    mockRequest(generatePaginatedContent<AudioTrack>('Audio', page, limit)),
  getAudioTrack: (id: string): Promise<AudioTrack> => mockContentItem<AudioTrack>('Audio', id),
  createAudio: (data: Partial<AudioTrack>): Promise<AudioTrack> => mockRequest({ id: String(Date.now()), ...data } as AudioTrack),
  updateAudio: (id: string, data: Partial<AudioTrack>): Promise<AudioTrack> =>
    mockRequest({ id, name: 'Updated Audio', ...data } as AudioTrack),
  deleteAudio: (id: string): Promise<void> => mockRequest(undefined),
  publishAudio: (id: string): Promise<void> => mockRequest(undefined),
  unpublishAudio: (id: string): Promise<void> => mockRequest(undefined),

  getTransitions: (page = 1, limit = 20): Promise<PaginatedResponse<Transition>> =>
    mockRequest(generatePaginatedContent<Transition>('Transition', page, limit)),
  getTransition: (id: string): Promise<Transition> => mockContentItem<Transition>('Transition', id),
  createTransition: (data: Partial<Transition>): Promise<Transition> => mockRequest({ id: String(Date.now()), ...data } as Transition),
  updateTransition: (id: string, data: Partial<Transition>): Promise<Transition> =>
    mockRequest({ id, name: 'Updated Transition', ...data } as Transition),
  deleteTransition: (id: string): Promise<void> => mockRequest(undefined),
  publishTransition: (id: string): Promise<void> => mockRequest(undefined),
  unpublishTransition: (id: string): Promise<void> => mockRequest(undefined),

  getColorGrades: (page = 1, limit = 20): Promise<PaginatedResponse<ColorGrade>> =>
    mockRequest(generatePaginatedContent<ColorGrade>('ColorGrade', page, limit)),
  getColorGrade: (id: string): Promise<ColorGrade> => mockContentItem<ColorGrade>('ColorGrade', id),
  createColorGrade: (data: Partial<ColorGrade>): Promise<ColorGrade> => mockRequest({ id: String(Date.now()), ...data } as ColorGrade),
  updateColorGrade: (id: string, data: Partial<ColorGrade>): Promise<ColorGrade> =>
    mockRequest({ id, name: 'Updated Color Grade', ...data } as ColorGrade),
  deleteColorGrade: (id: string): Promise<void> => mockRequest(undefined),
  publishColorGrade: (id: string): Promise<void> => mockRequest(undefined),
  unpublishColorGrade: (id: string): Promise<void> => mockRequest(undefined),

  getSubscriptions: (page = 1, limit = 20): Promise<PaginatedResponse<Subscription>> => {
    const subs = generateMockArray(30, i => ({
      id: String(i + 1), userId: String(i + 1), userName: `User ${i + 1}`,
      plan: ['free', 'pro', 'business', 'enterprise'][i % 4],
      status: (['active', 'canceled', 'expired', 'trialing'] as SubscriptionStatus[])[i % 4],
      price: [0, 19.99, 49.99, 99.99][i % 4],
      interval: (['monthly', 'yearly'] as const)[i % 2],
      currentPeriodStart: '2025-01-01T00:00:00Z',
      currentPeriodEnd: '2025-02-01T00:00:00Z',
      cancelAtPeriodEnd: i % 5 === 0,
      createdAt: new Date(Date.now() - Math.random() * 90 * 86400000).toISOString(),
    }))
    return mockRequest({
      data: subs.slice((page - 1) * limit, page * limit),
      total: subs.length, page, limit,
      totalPages: Math.ceil(subs.length / limit),
    })
  },

  updateSubscription: (id: string, data: Partial<Subscription>): Promise<Subscription> =>
    mockRequest({ id, plan: 'pro', status: 'active', price: 19.99, ...data } as Subscription),

  cancelSubscription: (id: string): Promise<void> => mockRequest(undefined),

  getCreditPackages: (): Promise<CreditPackage[]> =>
    mockRequest([
      { id: '1', name: 'Starter', credits: 100, price: 9.99, popular: false, active: true, createdAt: '2024-01-01T00:00:00Z' },
      { id: '2', name: 'Popular', credits: 500, price: 39.99, popular: true, active: true, createdAt: '2024-01-01T00:00:00Z' },
      { id: '3', name: 'Pro', credits: 2000, price: 129.99, popular: false, active: true, createdAt: '2024-01-01T00:00:00Z' },
      { id: '4', name: 'Ultimate', credits: 10000, price: 499.99, popular: false, active: true, createdAt: '2024-01-01T00:00:00Z' },
    ]),

  createCreditPackage: (data: Partial<CreditPackage>): Promise<CreditPackage> =>
    mockRequest({ id: String(Date.now()), ...data } as CreditPackage),

  updateCreditPackage: (id: string, data: Partial<CreditPackage>): Promise<CreditPackage> =>
    mockRequest({ id, ...data } as CreditPackage),

  togglePackageActive: (id: string): Promise<void> => mockRequest(undefined),

  getCreditTransactions: (page = 1, limit = 20): Promise<PaginatedResponse<CreditTransaction>> => {
    const txs = generateMockArray(50, i => ({
      id: String(i + 1), userId: String(Math.floor(Math.random() * 50) + 1),
      userName: `User ${Math.floor(Math.random() * 50) + 1}`,
      type: (['purchase', 'usage', 'refund', 'bonus'] as const)[i % 4],
      amount: i % 2 === 0 ? Math.floor(Math.random() * 1000) + 100 : -(Math.floor(Math.random() * 500) + 10),
      balance: Math.floor(Math.random() * 5000),
      description: ['Credit purchase', 'Export usage', 'Refund', 'Welcome bonus'][i % 4],
      createdAt: new Date(Date.now() - Math.random() * 30 * 86400000).toISOString(),
    }))
    return mockRequest({
      data: txs.slice((page - 1) * limit, page * limit),
      total: txs.length, page, limit,
      totalPages: Math.ceil(txs.length / limit),
    })
  },

  getAIGenerationJobs: (page = 1, limit = 20): Promise<PaginatedResponse<AIGenerationJob>> => {
    const jobs = generateMockArray(20, i => ({
      id: String(i + 1),
      type: (['effect', 'template', 'transition', 'metadata'] as const)[i % 4],
      input: { prompt: `Generate ${['effect', 'template', 'transition', 'metadata'][i % 4]}` },
      output: i % 3 === 0 ? { id: 'gen_' + i, url: null } : null,
      status: (['queued', 'processing', 'completed', 'failed'] as const)[i % 4],
      progress: i % 4 === 1 ? Math.floor(Math.random() * 100) : i % 4 === 0 ? 0 : 100,
      userId: String(Math.floor(Math.random() * 10) + 1),
      userName: `Creator ${Math.floor(Math.random() * 10) + 1}`,
      createdAt: new Date(Date.now() - Math.random() * 7 * 86400000).toISOString(),
      completedAt: i % 4 === 2 ? new Date(Date.now() - Math.random() * 2 * 86400000).toISOString() : null,
    }))
    return mockRequest({
      data: jobs.slice((page - 1) * limit, page * limit),
      total: jobs.length, page, limit,
      totalPages: Math.ceil(jobs.length / limit),
    })
  },

  submitAIGeneration: (type: string, input: Record<string, unknown>): Promise<AIGenerationJob> =>
    mockRequest({
      id: String(Date.now()), type: type as AIGenerationJob['type'],
      input, output: null, status: 'queued', progress: 0,
      userId: '1', userName: 'Admin User',
      createdAt: new Date().toISOString(), completedAt: null,
    }),

  reviewAIGeneration: (id: string, approved: boolean): Promise<void> => mockRequest(undefined),

  getAuditLogs: (page = 1, limit = 20): Promise<PaginatedResponse<AuditLog>> => {
    const logs = generateMockArray(100, i => ({
      id: String(i + 1),
      action: ['user.login', 'user.update', 'content.create', 'content.delete', 'settings.update', 'subscription.cancel'][i % 6],
      entity: ['User', 'Template', 'Project', 'Settings', 'Subscription'][i % 5],
      entityId: String(Math.floor(Math.random() * 100)),
      userId: String(Math.floor(Math.random() * 10) + 1),
      userName: `Admin ${Math.floor(Math.random() * 10) + 1}`,
      details: { changed: ['name', 'status', 'credits'][i % 3] },
      ip: `192.168.1.${Math.floor(Math.random() * 255)}`,
      createdAt: new Date(Date.now() - Math.random() * 30 * 86400000).toISOString(),
    }))
    return mockRequest({
      data: logs.slice((page - 1) * limit, page * limit),
      total: logs.length, page, limit,
      totalPages: Math.ceil(logs.length / limit),
    })
  },

  getFeatureFlags: (): Promise<FeatureFlag[]> =>
    mockRequest([
      { id: '1', key: 'ai_effects', name: 'AI Effects', description: 'Enable AI-powered effects', enabled: true, percentage: 100, createdAt: '2024-01-01T00:00:00Z', updatedAt: '2025-01-01T00:00:00Z' },
      { id: '2', key: 'ai_templates', name: 'AI Templates', description: 'Enable AI template generation', enabled: true, percentage: 50, createdAt: '2024-01-01T00:00:00Z', updatedAt: '2025-01-01T00:00:00Z' },
      { id: '3', key: 'collaboration', name: 'Collaboration', description: 'Enable real-time collaboration', enabled: false, percentage: 0, createdAt: '2024-01-01T00:00:00Z', updatedAt: '2025-01-01T00:00:00Z' },
      { id: '4', key: 'cloud_rendering', name: 'Cloud Rendering', description: 'Enable cloud-based rendering', enabled: true, percentage: 75, createdAt: '2024-01-01T00:00:00Z', updatedAt: '2025-01-01T00:00:00Z' },
    ]),

  createFeatureFlag: (data: Partial<FeatureFlag>): Promise<FeatureFlag> =>
    mockRequest({ id: String(Date.now()), ...data } as FeatureFlag),

  updateFeatureFlag: (id: string, data: Partial<FeatureFlag>): Promise<FeatureFlag> =>
    mockRequest({ id, ...data } as FeatureFlag),

  toggleFeatureFlag: (id: string): Promise<void> => mockRequest(undefined),

  getAppSettings: (): Promise<AppSettings> =>
    mockRequest({
      maintenanceMode: false, maintenanceMessage: '',
      forceUpdate: false, minimumAppVersion: '1.0.0',
      latestAppVersion: '1.2.0', updateUrl: 'https://popcut.com/download',
      maxUploadSize: 500, defaultCredits: 100, trialDays: 7,
    }),

  updateAppSettings: (data: Partial<AppSettings>): Promise<AppSettings> =>
    mockRequest({
      maintenanceMode: false, maintenanceMessage: '',
      forceUpdate: false, minimumAppVersion: '1.0.0',
      latestAppVersion: '1.2.0', updateUrl: 'https://popcut.com/download',
      maxUploadSize: 500, defaultCredits: 100, trialDays: 7,
      ...data,
    }),

  uploadAsset: (file: File): Promise<{ url: string }> =>
    mockRequest({ url: 'https://cdn.popcut.com/uploads/' + file.name }),
}

function generatePaginatedContent<T>(name: string, page: number, limit: number): PaginatedResponse<T> {
  const items = generateMockArray(30, i => ({
    id: String(i + 1),
    name: `${name} ${i + 1}`,
    description: `Description for ${name.toLowerCase()} item ${i + 1}`,
    category: ['popular', 'new', 'trending'][i % 3],
    thumbnail: null, preview: null,
    status: (['draft', 'published', 'archived'][i % 3] as ContentStatus),
    version: Math.floor(Math.random() * 5) + 1,
    author: `Creator ${(i % 10) + 1}`,
    usageCount: Math.floor(Math.random() * 5000),
    tags: ['trending', 'popular', 'new'],
    createdAt: new Date(Date.now() - Math.random() * 90 * 86400000).toISOString(),
    updatedAt: new Date(Date.now() - Math.random() * 30 * 86400000).toISOString(),
  })) as unknown as T[]
  return {
    data: items.slice((page - 1) * limit, page * limit),
    total: items.length, page, limit,
    totalPages: Math.ceil(items.length / limit),
  }
}

function mockContentItem<T>(name: string, id: string): Promise<T> {
  const item = {
    id, name: `${name} ${id}`, description: `A ${name.toLowerCase()} item`,
    category: 'popular', thumbnail: null, preview: null,
    status: 'published' as ContentStatus, version: 1, author: 'Creator',
    usageCount: 500, tags: ['popular'],
    createdAt: '2024-06-01T00:00:00Z', updatedAt: '2025-01-01T00:00:00Z',
  } as unknown as T
  return mockRequest(item)
}
