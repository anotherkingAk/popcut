import { HealthController } from './health.controller'

describe('HealthController', () => {
  let controller: HealthController

  beforeEach(() => {
    const mockHealthCheck = {
      check: vi.fn(),
    }
    const mockPrismaHealth = { pingCheck: vi.fn() }
    const mockMemoryHealth = { checkHeap: vi.fn() }
    const mockPrisma = {}

    controller = new (HealthController as any)(mockHealthCheck, mockPrismaHealth, mockMemoryHealth, mockPrisma)
  })

  it('should return health check status ok', async () => {
    const controllerAny = controller as any
    controllerAny.health.check = vi.fn().mockResolvedValue({
      status: 'ok',
      info: { database: { status: 'up' }, memory_heap: { status: 'up' } },
      error: {},
      details: { database: { status: 'up' }, memory_heap: { status: 'up' } },
    })

    const result = await controller.check()

    expect(result.status).toBe('ok')
    expect(result.info.database.status).toBe('up')
    expect(result.info.memory_heap.status).toBe('up')
  })

  it('should include database and memory health indicators', async () => {
    const controllerAny = controller as any
    controllerAny.health.check = vi.fn().mockResolvedValue({
      status: 'ok',
      info: { database: { status: 'up' }, memory_heap: { status: 'up' } },
      error: {},
      details: { database: { status: 'up' }, memory_heap: { status: 'up' } },
    })

    const result = await controller.check()

    expect(result.info).toHaveProperty('database')
    expect(result.info).toHaveProperty('memory_heap')
  })

  it('should fail when database is down', async () => {
    const controllerAny = controller as any
    controllerAny.health.check = vi.fn().mockResolvedValue({
      status: 'error',
      info: {},
      error: { database: { status: 'down', message: 'Connection refused' } },
      details: { database: { status: 'down', message: 'Connection refused' } },
    })

    const result = await controller.check()

    expect(result.status).toBe('error')
    expect(result.error.database.status).toBe('down')
  })
})
