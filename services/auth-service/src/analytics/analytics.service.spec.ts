import { AnalyticsService } from './analytics.service'

function makeService() {
  const mockPrisma = {
    user: { count: vi.fn() },
    analyticsEvent: { groupBy: vi.fn() },
    creditTransaction: { aggregate: vi.fn() },
    subscription: { aggregate: vi.fn() },
    aIJob: { count: vi.fn(), groupBy: vi.fn(), findMany: vi.fn() },
    exportJob: { count: vi.fn(), groupBy: vi.fn() },
    template: { count: vi.fn(), findMany: vi.fn() },
    effect: { count: vi.fn(), findMany: vi.fn() },
    project: { count: vi.fn() },
    audio: { count: vi.fn() },
    font: { count: vi.fn() },
    $queryRaw: vi.fn(),
  }
  const service = new AnalyticsService(mockPrisma as any)
  return { service, mockPrisma }
}

// $queryRaw is called as a tag function in template literals.
// Each dailyActiveUsers/monthlyActiveUsers call triggers:
//   - 2 inner $queryRaw calls for conditional SQL fragments (start/end date interpolation)
//   - 1 outer $queryRaw call for the actual query
// So for dailyActiveUsers with 2 queries = 6 total $queryRaw calls
function mockDailyActiveUsers(mockPrisma: any, rows: any[], unique: any[]) {
  mockPrisma.$queryRaw
    .mockResolvedValueOnce([]) // inner startDate fragment
    .mockResolvedValueOnce([]) // inner endDate fragment
    .mockResolvedValueOnce(rows) // outer query: daily rows
    .mockResolvedValueOnce([]) // inner startDate fragment (unique query)
    .mockResolvedValueOnce([]) // inner endDate fragment (unique query)
    .mockResolvedValueOnce(unique) // outer query: unique users
}

function mockMonthlyActiveUsers(mockPrisma: any, rows: any[]) {
  mockPrisma.$queryRaw
    .mockResolvedValueOnce([]) // inner startDate fragment
    .mockResolvedValueOnce([]) // inner endDate fragment
    .mockResolvedValueOnce(rows) // outer query
}

describe('AnalyticsService', () => {
  describe('revenue', () => {
    it('should return revenue metrics', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.creditTransaction.aggregate.mockResolvedValue({ _sum: { amount: 1000 }, _count: 10 })
      mockPrisma.subscription.aggregate.mockResolvedValue({ _sum: { price: 500 } })

      const result = await service.revenue()

      expect(result).toEqual({ creditRevenue: 1000, creditTransactions: 10, subscriptionRevenue: 500, total: 1500 })
    })

    it('should default to zero when no revenue', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.creditTransaction.aggregate.mockResolvedValue({ _sum: { amount: null }, _count: 0 })
      mockPrisma.subscription.aggregate.mockResolvedValue({ _sum: { price: null } })

      const result = await service.revenue()

      expect(result).toEqual({ creditRevenue: 0, creditTransactions: 0, subscriptionRevenue: 0, total: 0 })
    })

    it('should pass date filters when provided', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.creditTransaction.aggregate.mockResolvedValue({ _sum: { amount: 100 }, _count: 1 })
      mockPrisma.subscription.aggregate.mockResolvedValue({ _sum: { price: 50 } })

      await service.revenue('2024-01-01', '2024-12-31')

      const creditWhere = mockPrisma.creditTransaction.aggregate.mock.calls[0][0]
      expect(creditWhere.where.createdAt).toBeDefined()
    })
  })

  describe('dailyActiveUsers', () => {
    it('should return daily active users', async () => {
      const { service, mockPrisma } = makeService()
      const mockRows = [
        { date: new Date('2024-01-01'), count: BigInt(5) },
        { date: new Date('2024-01-02'), count: BigInt(3) },
      ]
      const mockUnique = [{ userId: 'u1' }, { userId: 'u2' }, { userId: 'u3' }]
      mockDailyActiveUsers(mockPrisma, mockRows, mockUnique)

      const result = await service.dailyActiveUsers()

      expect(result).toEqual({
        dailyActiveUsers: [{ date: '2024-01-01', count: 5 }, { date: '2024-01-02', count: 3 }],
        totalUniqueActive: 3,
      })
    })

    it('should return empty when no events', async () => {
      const { service, mockPrisma } = makeService()
      mockDailyActiveUsers(mockPrisma, [], [])

      const result = await service.dailyActiveUsers()

      expect(result).toEqual({ dailyActiveUsers: [], totalUniqueActive: 0 })
    })
  })

  describe('monthlyActiveUsers', () => {
    it('should return monthly active users', async () => {
      const { service, mockPrisma } = makeService()
      const mockRows = [
        { month: '2024-01', count: BigInt(10) },
        { month: '2024-02', count: BigInt(15) },
      ]
      mockMonthlyActiveUsers(mockPrisma, mockRows)

      const result = await service.monthlyActiveUsers()

      expect(result).toEqual({
        monthlyActiveUsers: [{ month: '2024-01', count: 10 }, { month: '2024-02', count: 15 }],
      })
    })
  })

  describe('retention', () => {
    it('should calculate retention rates', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.count.mockResolvedValue(100)
      mockPrisma.analyticsEvent.groupBy
        .mockResolvedValueOnce([{ userId: 'u1' }, { userId: 'u2' }, { userId: 'u3' }])
        .mockResolvedValueOnce([{ userId: 'u1' }, { userId: 'u2' }, { userId: 'u3' }, { userId: 'u4' }, { userId: 'u5' }])

      const result = await service.retention()

      expect(result).toEqual({ totalUsers: 100, active7Days: 3, active30Days: 5, retention7d: 3, retention30d: 5 })
    })

    it('should return zero rates when no users', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.count.mockResolvedValue(0)
      mockPrisma.analyticsEvent.groupBy.mockResolvedValueOnce([]).mockResolvedValueOnce([])

      const result = await service.retention()

      expect(result).toEqual({ totalUsers: 0, active7Days: 0, active30Days: 0, retention7d: 0, retention30d: 0 })
    })
  })

  describe('aiUsage', () => {
    it('should return AI usage stats', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.aIJob.count.mockResolvedValue(10)
      mockPrisma.aIJob.groupBy.mockResolvedValueOnce([{ type: 'caption', _count: 5 }]).mockResolvedValueOnce([{ status: 'completed', _count: 3 }])
      mockPrisma.aIJob.findMany.mockResolvedValue([{ id: 'job-1', user: { id: 'u1', email: 'test@test.com', name: 'Test' } }])

      const result = await service.aiUsage()

      expect(result.total).toBe(10)
      expect(result.byType).toEqual([{ type: 'caption', _count: 5 }])
    })
  })

  describe('exportUsage', () => {
    it('should return export usage stats', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.exportJob.count.mockResolvedValue(5)
      mockPrisma.exportJob.groupBy.mockResolvedValueOnce([{ format: 'mp4', _count: 3 }]).mockResolvedValueOnce([{ status: 'completed', _count: 2 }])

      const result = await service.exportUsage()

      expect(result).toEqual({ total: 5, byFormat: [{ format: 'mp4', _count: 3 }], byStatus: [{ status: 'completed', _count: 2 }] })
    })
  })

  describe('popularTemplates', () => {
    it('should return popular templates', async () => {
      const { service, mockPrisma } = makeService()
      const mockTemplates = [{ id: 'tpl-1', name: 'Popular', usageCount: 100 }]
      mockPrisma.template.findMany.mockResolvedValue(mockTemplates)

      const result = await service.popularTemplates(5)

      expect(mockPrisma.template.findMany).toHaveBeenCalledWith({ orderBy: { usageCount: 'desc' }, take: 5, select: expect.any(Object) })
      expect(result).toEqual(mockTemplates)
    })
  })

  describe('popularEffects', () => {
    it('should return popular effects', async () => {
      const { service, mockPrisma } = makeService()
      const mockEffects = [{ id: 'eff-1', name: 'Popular Effect' }]
      mockPrisma.effect.findMany.mockResolvedValue(mockEffects)

      const result = await service.popularEffects(3)

      expect(mockPrisma.effect.findMany).toHaveBeenCalledWith({ orderBy: { createdAt: 'desc' }, take: 3, select: expect.any(Object) })
      expect(result).toEqual(mockEffects)
    })
  })

  describe('storage', () => {
    it('should return storage counts', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.project.count.mockResolvedValue(50)
      mockPrisma.template.count.mockResolvedValue(30)
      mockPrisma.audio.count.mockResolvedValue(20)
      mockPrisma.font.count.mockResolvedValue(15)

      const result = await service.storage()

      expect(result).toEqual({ projects: 50, templates: 30, audio: 20, fonts: 15 })
    })
  })
})
