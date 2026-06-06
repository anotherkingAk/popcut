export type AdminRole = 'owner' | 'admin' | 'moderator' | 'support'

export type ContentStatus = 'draft' | 'published' | 'archived'
export type SubscriptionStatus = 'active' | 'canceled' | 'expired' | 'trialing'
export type AIJobStatus = 'queued' | 'processing' | 'completed' | 'failed'
export type ExportStatus = 'pending' | 'processing' | 'completed' | 'failed'

export interface AdminUser {
  id: string
  email: string
  name: string | null
  avatar: string | null
  role: AdminRole
  status: 'active' | 'suspended'
  credits: number
  subscriptionTier: string | null
  projectsCount: number
  totalExports: number
  storageUsed: number
  createdAt: string
  updatedAt: string
}

export interface Project {
  id: string
  name: string
  userId: string
  userName: string
  thumbnail: string | null
  duration: number
  status: 'draft' | 'processing' | 'completed'
  templateId: string | null
  exportsCount: number
  createdAt: string
  updatedAt: string
}

export interface Template {
  id: string
  name: string
  description: string
  category: string
  thumbnail: string | null
  preview: string | null
  duration: number
  status: ContentStatus
  version: number
  author: string
  usageCount: number
  tags: string[]
  createdAt: string
  updatedAt: string
}

export interface Effect {
  id: string
  name: string
  description: string
  type: 'visual' | 'audio' | 'text'
  category: string
  thumbnail: string | null
  preview: string | null
  status: ContentStatus
  version: number
  author: string
  usageCount: number
  tags: string[]
  params: Record<string, unknown>
  createdAt: string
  updatedAt: string
}

export interface Filter {
  id: string
  name: string
  description: string
  category: string
  thumbnail: string | null
  preview: string | null
  intensity: number
  status: ContentStatus
  version: number
  author: string
  usageCount: number
  tags: string[]
  lutId: string | null
  createdAt: string
  updatedAt: string
}

export interface Font {
  id: string
  name: string
  family: string
  weight: number[]
  styles: string[]
  format: string
  fileSize: number
  source: 'system' | 'custom' | 'google'
  preview: string | null
  status: ContentStatus
  author: string
  usageCount: number
  createdAt: string
  updatedAt: string
}

export interface AudioTrack {
  id: string
  name: string
  artist: string | null
  duration: number
  category: string
  fileUrl: string
  waveform: string | null
  status: ContentStatus
  version: number
  author: string
  usageCount: number
  tags: string[]
  bpm: number | null
  mood: string[]
  createdAt: string
  updatedAt: string
}

export interface Transition {
  id: string
  name: string
  description: string
  category: string
  type: 'dissolve' | 'wipe' | 'slide' | 'zoom' | 'custom'
  duration: number
  thumbnail: string | null
  preview: string | null
  status: ContentStatus
  version: number
  author: string
  usageCount: number
  params: Record<string, unknown>
  createdAt: string
  updatedAt: string
}

export interface ColorGrade {
  id: string
  name: string
  description: string
  category: string
  thumbnail: string | null
  lutFile: string | null
  intensity: number
  status: ContentStatus
  version: number
  author: string
  usageCount: number
  tags: string[]
  createdAt: string
  updatedAt: string
}

export interface DashboardMetrics {
  dau: number
  mau: number
  revenue: number
  revenueChange: number
  activeExports: number
  aiUsage: number
  storageUsed: number
  totalUsers: number
  newUsersToday: number
  totalProjects: number
}

export interface AnalyticsData {
  dailyActiveUsers: { date: string; value: number }[]
  revenue: { date: string; value: number }[]
  userGrowth: { date: string; value: number }[]
  exports: { date: string; value: number }[]
  aiUsage: { date: string; value: number }[]
  storage: { date: string; value: number }[]
}

export interface ExportRecord {
  id: string
  userId: string
  userName: string
  projectId: string
  projectName: string
  format: string
  resolution: string
  duration: number
  fileSize: number
  status: ExportStatus
  progress: number
  createdAt: string
  completedAt: string | null
}

export interface Subscription {
  id: string
  userId: string
  userName: string
  plan: string
  status: SubscriptionStatus
  price: number
  interval: 'monthly' | 'yearly'
  currentPeriodStart: string
  currentPeriodEnd: string
  cancelAtPeriodEnd: boolean
  createdAt: string
}

export interface CreditPackage {
  id: string
  name: string
  credits: number
  price: number
  popular: boolean
  active: boolean
  createdAt: string
}

export interface CreditTransaction {
  id: string
  userId: string
  userName: string
  type: 'purchase' | 'usage' | 'refund' | 'bonus'
  amount: number
  balance: number
  description: string
  createdAt: string
}

export interface AuditLog {
  id: string
  action: string
  entity: string
  entityId: string
  userId: string
  userName: string
  details: Record<string, unknown>
  ip: string
  createdAt: string
}

export interface FeatureFlag {
  id: string
  key: string
  name: string
  description: string
  enabled: boolean
  percentage: number
  createdAt: string
  updatedAt: string
}

export interface AppSettings {
  maintenanceMode: boolean
  maintenanceMessage: string
  forceUpdate: boolean
  minimumAppVersion: string
  latestAppVersion: string
  updateUrl: string
  maxUploadSize: number
  defaultCredits: number
  trialDays: number
}

export interface AIGenerationJob {
  id: string
  type: 'effect' | 'template' | 'transition' | 'metadata'
  input: Record<string, unknown>
  output: Record<string, unknown> | null
  status: AIJobStatus
  progress: number
  userId: string
  userName: string
  createdAt: string
  completedAt: string | null
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
  totalPages: number
}
