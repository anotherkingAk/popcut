import { NotFoundException } from '@nestjs/common'
import { AdminService } from './admin.service'

describe('AdminService', () => {
  function makeService(findUniqueResult?: any) {
    const mockPrisma = {
      user: { count: vi.fn(), findMany: vi.fn(), findUnique: vi.fn(), update: vi.fn(), delete: vi.fn() },
      project: { count: vi.fn(), findMany: vi.fn(), delete: vi.fn() },
      template: { count: vi.fn(), findMany: vi.fn(), create: vi.fn(), update: vi.fn(), delete: vi.fn() },
      effect: { count: vi.fn(), findMany: vi.fn(), create: vi.fn(), update: vi.fn(), delete: vi.fn() },
      filter: { count: vi.fn(), findMany: vi.fn(), create: vi.fn(), update: vi.fn(), delete: vi.fn() },
      font: { count: vi.fn(), findMany: vi.fn(), create: vi.fn(), update: vi.fn(), delete: vi.fn() },
      audio: { count: vi.fn(), findMany: vi.fn(), create: vi.fn(), update: vi.fn(), delete: vi.fn() },
      subscription: { count: vi.fn(), findMany: vi.fn(), update: vi.fn() },
      aIJob: { count: vi.fn(), findMany: vi.fn(), findUnique: vi.fn(), update: vi.fn() },
      exportJob: { count: vi.fn(), findMany: vi.fn() },
      auditLog: { count: vi.fn(), findMany: vi.fn() },
      featureFlag: { findMany: vi.fn(), create: vi.fn(), update: vi.fn(), delete: vi.fn() },
      creditTransaction: { count: vi.fn(), findMany: vi.fn(), create: vi.fn(), aggregate: vi.fn() },
    }
    const service = new AdminService(mockPrisma as any)
    return { service, mockPrisma }
  }

  describe('getDashboard', () => {
    it('should return aggregated dashboard data', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.count.mockResolvedValue(100)
      mockPrisma.project.count.mockResolvedValue(50)
      mockPrisma.template.count.mockResolvedValue(30)
      mockPrisma.effect.count.mockResolvedValue(20)
      mockPrisma.aIJob.count.mockResolvedValue(5)
      mockPrisma.creditTransaction.aggregate.mockResolvedValue({ _sum: { amount: 10000 } })
      mockPrisma.user.findMany.mockResolvedValue([{ id: 'u1', email: 'a@b.com', name: 'A', createdAt: new Date() }])

      const result = await service.getDashboard()

      expect(result).toEqual({
        users: 100, projects: 50, templates: 30, effects: 20, activeJobs: 5,
        revenue: 10000, recentUsers: [expect.objectContaining({ id: 'u1' })],
      })
    })

    it('should default revenue to zero', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.count.mockResolvedValue(0)
      mockPrisma.project.count.mockResolvedValue(0)
      mockPrisma.template.count.mockResolvedValue(0)
      mockPrisma.effect.count.mockResolvedValue(0)
      mockPrisma.aIJob.count.mockResolvedValue(0)
      mockPrisma.creditTransaction.aggregate.mockResolvedValue({ _sum: { amount: null } })
      mockPrisma.user.findMany.mockResolvedValue([])

      const result = await service.getDashboard()

      expect(result.revenue).toBe(0)
    })
  })

  describe('listUsers', () => {
    it('should return paginated users', async () => {
      const { service, mockPrisma } = makeService()
      const mockUsers = [{ id: 'u1', email: 'a@b.com', name: 'A', avatar: null, credits: 10, isActive: true, createdAt: new Date(), updatedAt: new Date() }]
      mockPrisma.user.findMany.mockResolvedValue(mockUsers)
      mockPrisma.user.count.mockResolvedValue(1)

      const result = await service.listUsers(1, 20)

      expect(result).toEqual({ data: mockUsers, total: 1, page: 1, limit: 20, totalPages: 1 })
    })

    it('should compute totalPages correctly', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.findMany.mockResolvedValue([])
      mockPrisma.user.count.mockResolvedValue(25)

      const result = await service.listUsers(1, 10)

      expect(result.totalPages).toBe(3)
    })
  })

  describe('getUser', () => {
    it('should return user by id', async () => {
      const { service, mockPrisma } = makeService()
      const mockUser = { id: 'u1', email: 'a@b.com', name: 'A', role: 'USER' }
      mockPrisma.user.findUnique.mockResolvedValue(mockUser)

      const result = await service.getUser('u1')

      expect(result).toEqual(mockUser)
    })

    it('should throw NotFoundException if user not found', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.findUnique.mockResolvedValue(null)
      await expect(service.getUser('nonexistent')).rejects.toThrow(NotFoundException)
    })
  })

  describe('updateUser', () => {
    it('should update and return user', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'u1', email: 'a@b.com' })
      mockPrisma.user.update.mockResolvedValue({ id: 'u1', name: 'New' })

      const result = await service.updateUser('u1', { name: 'New' })

      expect(mockPrisma.user.update).toHaveBeenCalledWith({ where: { id: 'u1' }, data: { name: 'New' } })
      expect(result.name).toBe('New')
    })

    it('should throw NotFoundException if user not found', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.findUnique.mockImplementation(() => Promise.resolve(null))
      await expect(service.updateUser('nonexistent', { name: 'New' })).rejects.toThrow(NotFoundException)
    })
  })

  describe('deleteUser', () => {
    it('should delete user', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.findUnique.mockImplementation(() => Promise.resolve({ id: 'u1' }))
      mockPrisma.user.delete.mockImplementation(() => Promise.resolve({}))

      const result = await service.deleteUser('u1')

      expect(result).toEqual({ message: 'User deleted' })
    })

    it('should throw NotFoundException if user not found', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.user.findUnique.mockImplementation(() => Promise.resolve(null))
      await expect(service.deleteUser('nonexistent')).rejects.toThrow(NotFoundException)
    })
  })

  describe('listProjects', () => {
    it('should return paginated projects', async () => {
      const { service, mockPrisma } = makeService()
      const mockProjects = [{ id: 'p1', name: 'Project 1', user: { id: 'u1', email: 'a@b.com', name: 'A' } }]
      mockPrisma.project.findMany.mockResolvedValue(mockProjects)
      mockPrisma.project.count.mockResolvedValue(1)

      const result = await service.listProjects(1, 20)

      expect(result.data).toEqual(mockProjects)
    })
  })

  describe('deleteProject', () => {
    it('should delete project', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.project.delete.mockResolvedValue({})
      expect(await service.deleteProject('p1')).toEqual({ message: 'Project deleted' })
    })
  })

  describe('listSubscriptions', () => {
    it('should return paginated subscriptions', async () => {
      const { service, mockPrisma } = makeService()
      const mockData = [{ id: 's1', user: { id: 'u1', email: 'a@b.com', name: 'A' } }]
      mockPrisma.subscription.findMany.mockResolvedValue(mockData)
      mockPrisma.subscription.count.mockResolvedValue(1)

      const result = await service.listSubscriptions(1)

      expect(result.data).toEqual(mockData)
    })
  })

  describe('retryAIJob', () => {
    it('should retry a failed job', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.aIJob.findUnique.mockResolvedValue({ id: 'j1', status: 'failed' })
      mockPrisma.aIJob.update.mockResolvedValue({ id: 'j1', status: 'queued', error: null, progress: 0 })

      await service.retryAIJob('j1')
      expect(mockPrisma.aIJob.update).toHaveBeenCalledWith({ where: { id: 'j1' }, data: { status: 'queued', error: null, progress: 0 } })
    })

    it('should throw NotFoundException if job not found', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.aIJob.findUnique.mockImplementation(() => Promise.resolve(null))
      await expect(service.retryAIJob('nonexistent')).rejects.toThrow(NotFoundException)
    })
  })

  describe('listFeatureFlags', () => {
    it('should return feature flags', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.featureFlag.findMany.mockResolvedValue([{ id: 'f1', name: 'test-flag', enabled: false }])
      const result = await service.listFeatureFlags()
      expect(result).toEqual([{ id: 'f1', name: 'test-flag', enabled: false }])
    })
  })

  describe('updateFeatureFlag', () => {
    it('should update feature flag', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.featureFlag.update.mockResolvedValue({ id: 'f1', enabled: true })
      await service.updateFeatureFlag('f1', { enabled: true })
      expect(mockPrisma.featureFlag.update).toHaveBeenCalledWith({ where: { id: 'f1' }, data: { enabled: true } })
    })
  })

  describe('createFeatureFlag', () => {
    it('should create feature flag', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.featureFlag.create.mockResolvedValue({ id: 'f1', name: 'new-flag' })
      const result = await service.createFeatureFlag({ name: 'new-flag' })
      expect(result.id).toBe('f1')
    })
  })

  describe('deleteFeatureFlag', () => {
    it('should delete feature flag', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.featureFlag.delete.mockResolvedValue({})
      expect(await service.deleteFeatureFlag('f1')).toEqual({ message: 'Feature flag deleted' })
    })
  })

  describe('listCreditTransactions', () => {
    it('should return paginated credit transactions', async () => {
      const { service, mockPrisma } = makeService()
      const mockData = [{ id: 'ct1', user: { id: 'u1', email: 'a@b.com', name: 'A' } }]
      mockPrisma.creditTransaction.findMany.mockResolvedValue(mockData)
      mockPrisma.creditTransaction.count.mockResolvedValue(1)

      const result = await service.listCreditTransactions(1, 20)

      expect(result.data).toEqual(mockData)
    })
  })

  describe('createCreditTransaction', () => {
    it('should create credit transaction', async () => {
      const { service, mockPrisma } = makeService()
      mockPrisma.creditTransaction.create.mockResolvedValue({ id: 'ct1', userId: 'u1', amount: 100, type: 'purchase' })
      const result = await service.createCreditTransaction({ userId: 'u1', amount: 100, type: 'purchase' })
      expect(result.id).toBe('ct1')
    })
  })
})
