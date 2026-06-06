import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaClient, Role } from '@prisma/client'

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaClient) {}

  // --- Dashboard ---
  async getDashboard() {
    const [users, projects, templates, effects, activeJobs, revenue] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.project.count(),
      this.prisma.template.count(),
      this.prisma.effect.count(),
      this.prisma.aIJob.count({ where: { status: 'processing' } }),
      this.prisma.creditTransaction.aggregate({ _sum: { amount: true } }),
    ])
    const recentUsers = await this.prisma.user.findMany({
      orderBy: { createdAt: 'desc' }, take: 5,
      select: { id: true, email: true, name: true, createdAt: true },
    })
    return { users, projects, templates, effects, activeJobs, revenue: revenue._sum.amount || 0, recentUsers }
  }

  // --- Users ---
  async listUsers(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        skip, take: limit,
        orderBy: { createdAt: 'desc' },
        select: { id: true, email: true, name: true, avatar: true, credits: true, isActive: true, createdAt: true, updatedAt: true },
      }),
      this.prisma.user.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async getUser(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true, email: true, name: true, avatar: true, role: true,
        credits: true, isActive: true, planId: true, lastLoginAt: true,
        createdAt: true, updatedAt: true, deletedAt: true,
      },
    })
    if (!user) throw new NotFoundException('User not found')
    return user
  }

  async updateUser(id: string, data: { name?: string; role?: Role; isActive?: boolean; credits?: number }) {
    const user = await this.prisma.user.findUnique({ where: { id } })
    if (!user) throw new NotFoundException('User not found')
    return this.prisma.user.update({ where: { id }, data })
  }

  async deleteUser(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } })
    if (!user) throw new NotFoundException('User not found')
    await this.prisma.user.delete({ where: { id } })
    return { message: 'User deleted' }
  }

  // --- Projects ---
  async listProjects(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.project.findMany({
        skip, take: limit, orderBy: { updatedAt: 'desc' },
        include: { user: { select: { id: true, email: true, name: true } } },
      }),
      this.prisma.project.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async deleteProject(id: string) {
    await this.prisma.project.delete({ where: { id } })
    return { message: 'Project deleted' }
  }

  // --- Templates ---
  async listTemplates(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.template.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        select: {
          id: true, name: true, thumbnail: true, category: true,
          isPublic: true, isPremium: true, price: true, usageCount: true, createdAt: true,
        },
      }),
      this.prisma.template.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async createTemplate(data: any) {
    return this.prisma.template.create({ data })
  }

  async updateTemplate(id: string, data: any) {
    return this.prisma.template.update({ where: { id }, data })
  }

  async deleteTemplate(id: string) {
    await this.prisma.template.delete({ where: { id } })
    return { message: 'Template deleted' }
  }

  // --- Effects ---
  async listEffects(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.effect.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        select: {
          id: true, name: true, thumbnail: true, type: true, category: true,
          isPublic: true, isPremium: true, createdAt: true,
        },
      }),
      this.prisma.effect.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async createEffect(data: any) {
    return this.prisma.effect.create({ data })
  }

  async updateEffect(id: string, data: any) {
    return this.prisma.effect.update({ where: { id }, data })
  }

  async deleteEffect(id: string) {
    await this.prisma.effect.delete({ where: { id } })
    return { message: 'Effect deleted' }
  }

  // --- Filters ---
  async listFilters(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.filter.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        select: {
          id: true, name: true, thumbnail: true, category: true,
          isPublic: true, isPremium: true, createdAt: true,
        },
      }),
      this.prisma.filter.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async createFilter(data: any) {
    return this.prisma.filter.create({ data })
  }

  async updateFilter(id: string, data: any) {
    return this.prisma.filter.update({ where: { id }, data })
  }

  async deleteFilter(id: string) {
    await this.prisma.filter.delete({ where: { id } })
    return { message: 'Filter deleted' }
  }

  // --- Fonts ---
  async listFonts(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.font.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        select: {
          id: true, name: true, family: true, category: true,
          isPublic: true, isPremium: true, createdAt: true,
        },
      }),
      this.prisma.font.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async createFont(data: any) {
    return this.prisma.font.create({ data })
  }

  async updateFont(id: string, data: any) {
    return this.prisma.font.update({ where: { id }, data })
  }

  async deleteFont(id: string) {
    await this.prisma.font.delete({ where: { id } })
    return { message: 'Font deleted' }
  }

  // --- Audio ---
  async listAudio(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.audio.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        select: {
          id: true, name: true, duration: true, category: true,
          isPublic: true, isPremium: true, createdAt: true,
        },
      }),
      this.prisma.audio.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async createAudio(data: any) {
    return this.prisma.audio.create({ data })
  }

  async updateAudio(id: string, data: any) {
    return this.prisma.audio.update({ where: { id }, data })
  }

  async deleteAudio(id: string) {
    await this.prisma.audio.delete({ where: { id } })
    return { message: 'Audio deleted' }
  }

  // --- Subscriptions ---
  async listSubscriptions(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.subscription.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        include: { user: { select: { id: true, email: true, name: true } } },
      }),
      this.prisma.subscription.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async updateSubscription(id: string, data: any) {
    return this.prisma.subscription.update({ where: { id }, data })
  }

  // --- AI Jobs ---
  async listAIJobs(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.aIJob.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        include: { user: { select: { id: true, email: true, name: true } } },
      }),
      this.prisma.aIJob.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async retryAIJob(id: string) {
    const job = await this.prisma.aIJob.findUnique({ where: { id } })
    if (!job) throw new NotFoundException('Job not found')
    return this.prisma.aIJob.update({ where: { id }, data: { status: 'queued', error: null, progress: 0 } })
  }

  // --- Export Jobs ---
  async listExportJobs(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.exportJob.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        include: { user: { select: { id: true, email: true, name: true } }, project: { select: { id: true, name: true } } },
      }),
      this.prisma.exportJob.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  // --- Audit Logs ---
  async listAuditLogs(page = 1, limit = 50) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        include: { user: { select: { id: true, email: true, name: true } } },
      }),
      this.prisma.auditLog.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  // --- Feature Flags ---
  async listFeatureFlags() {
    return this.prisma.featureFlag.findMany({ orderBy: { name: 'asc' } })
  }

  async updateFeatureFlag(id: string, data: { enabled?: boolean; description?: string; rules?: any }) {
    return this.prisma.featureFlag.update({ where: { id }, data })
  }

  async createFeatureFlag(data: { name: string; enabled?: boolean; description?: string; rules?: any }) {
    return this.prisma.featureFlag.create({ data })
  }

  async deleteFeatureFlag(id: string) {
    await this.prisma.featureFlag.delete({ where: { id } })
    return { message: 'Feature flag deleted' }
  }

  // --- Credit Transactions ---
  async listCreditTransactions(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.creditTransaction.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        include: { user: { select: { id: true, email: true, name: true } } },
      }),
      this.prisma.creditTransaction.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async createCreditTransaction(data: { userId: string; amount: number; type: string; reference?: string; description?: string }) {
    return this.prisma.creditTransaction.create({ data })
  }
}
