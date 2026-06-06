import { Injectable } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Injectable()
export class AnalyticsService {
  constructor(private readonly prisma: PrismaClient) {}

  private dateFilter(start?: string, end?: string) {
    const filter: Record<string, Date> = {}
    if (start) filter.gte = new Date(start)
    if (end) filter.lte = new Date(end)
    return Object.keys(filter).length ? filter : undefined
  }

  async revenue(start?: string, end?: string) {
    const dateFilter = this.dateFilter(start, end)
    const where = dateFilter ? { createdAt: dateFilter } : {}
    const creditRevenue = await this.prisma.creditTransaction.aggregate({
      where: { ...where, type: 'purchase' },
      _sum: { amount: true },
      _count: true,
    })
    const subscriptionRevenue = await this.prisma.subscription.aggregate({
      where: { ...where, status: 'active' },
      _sum: { price: true },
    })
    return {
      creditRevenue: creditRevenue._sum.amount || 0,
      creditTransactions: creditRevenue._count,
      subscriptionRevenue: subscriptionRevenue._sum.price || 0,
      total: (creditRevenue._sum.amount || 0) + (subscriptionRevenue._sum.price || 0),
    }
  }

  async dailyActiveUsers(start?: string, end?: string) {
    const startDate = start ? new Date(start) : undefined
    const endDate = end ? new Date(end) : undefined
    const rows: Array<{ date: Date; count: bigint }> = await this.prisma.$queryRaw`
      SELECT date_trunc('day', created_at) as date,
             COUNT(DISTINCT user_id) as count
      FROM analytics_events
      WHERE event = 'page_view'
        AND user_id IS NOT NULL
        ${startDate ? this.prisma.$queryRaw`AND created_at >= ${startDate}` : this.prisma.$queryRaw``}
        ${endDate ? this.prisma.$queryRaw`AND created_at <= ${endDate}` : this.prisma.$queryRaw``}
      GROUP BY date_trunc('day', created_at)
      ORDER BY date ASC
    `
    const dailyActiveUsers = rows.map(r => ({
      date: r.date.toISOString().split('T')[0],
      count: Number(r.count),
    }))
    const unique: Array<{ userId: string }> = await this.prisma.$queryRaw`
      SELECT DISTINCT user_id as "userId"
      FROM analytics_events
      WHERE event = 'page_view'
        AND user_id IS NOT NULL
        ${startDate ? this.prisma.$queryRaw`AND created_at >= ${startDate}` : this.prisma.$queryRaw``}
        ${endDate ? this.prisma.$queryRaw`AND created_at <= ${endDate}` : this.prisma.$queryRaw``}
    `
    return { dailyActiveUsers, totalUniqueActive: unique.length }
  }

  async monthlyActiveUsers(start?: string, end?: string) {
    const startDate = start ? new Date(start) : undefined
    const endDate = end ? new Date(end) : undefined
    const rows: Array<{ month: string; count: bigint }> = await this.prisma.$queryRaw`
      SELECT to_char(date_trunc('month', created_at), 'YYYY-MM') as month,
             COUNT(DISTINCT user_id) as count
      FROM analytics_events
      WHERE event = 'page_view'
        AND user_id IS NOT NULL
        ${startDate ? this.prisma.$queryRaw`AND created_at >= ${startDate}` : this.prisma.$queryRaw``}
        ${endDate ? this.prisma.$queryRaw`AND created_at <= ${endDate}` : this.prisma.$queryRaw``}
      GROUP BY date_trunc('month', created_at)
      ORDER BY month ASC
    `
    return { monthlyActiveUsers: rows.map(r => ({ month: String(r.month), count: Number(r.count) })) }
  }

  async retention() {
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    const [totalUsers, active7d, active30d] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.analyticsEvent.groupBy({
        by: ['userId'],
        where: { createdAt: { gte: sevenDaysAgo }, event: 'page_view', userId: { not: null } },
      }),
      this.prisma.analyticsEvent.groupBy({
        by: ['userId'],
        where: { createdAt: { gte: thirtyDaysAgo }, event: 'page_view', userId: { not: null } },
      }),
    ])
    return {
      totalUsers,
      active7Days: active7d.length,
      active30Days: active30d.length,
      retention7d: totalUsers ? Math.round((active7d.length / totalUsers) * 100) : 0,
      retention30d: totalUsers ? Math.round((active30d.length / totalUsers) * 100) : 0,
    }
  }

  async aiUsage(start?: string, end?: string) {
    const dateFilter = this.dateFilter(start, end)
    const where = dateFilter ? { createdAt: dateFilter } : {}
    const [total, byType, byStatus, recent] = await Promise.all([
      this.prisma.aIJob.count({ where }),
      this.prisma.aIJob.groupBy({ by: ['type'], where, _count: true }),
      this.prisma.aIJob.groupBy({ by: ['status'], where, _count: true }),
      this.prisma.aIJob.findMany({
        where, orderBy: { createdAt: 'desc' }, take: 5,
        include: { user: { select: { id: true, email: true, name: true } } },
      }),
    ])
    return { total, byType, byStatus, recent }
  }

  async exportUsage(start?: string, end?: string) {
    const dateFilter = this.dateFilter(start, end)
    const where = dateFilter ? { createdAt: dateFilter } : {}
    const [total, byFormat, byStatus] = await Promise.all([
      this.prisma.exportJob.count({ where }),
      this.prisma.exportJob.groupBy({ by: ['format'], where, _count: true }),
      this.prisma.exportJob.groupBy({ by: ['status'], where, _count: true }),
    ])
    return { total, byFormat, byStatus }
  }

  async popularTemplates(limit = 10) {
    return this.prisma.template.findMany({
      orderBy: { usageCount: 'desc' },
      take: limit,
      select: {
        id: true, name: true, thumbnail: true, category: true,
        isPublic: true, isPremium: true, price: true, usageCount: true, createdAt: true,
      },
    })
  }

  async popularEffects(limit = 10) {
    return this.prisma.effect.findMany({
      orderBy: { createdAt: 'desc' },
      take: limit,
      select: {
        id: true, name: true, type: true, thumbnail: true, category: true,
        isPublic: true, isPremium: true, createdAt: true,
      },
    })
  }

  async storage() {
    const [projects, templates, audio, fonts] = await Promise.all([
      this.prisma.project.count(),
      this.prisma.template.count(),
      this.prisma.audio.count(),
      this.prisma.font.count(),
    ])
    return { projects, templates, audio, fonts }
  }
}
