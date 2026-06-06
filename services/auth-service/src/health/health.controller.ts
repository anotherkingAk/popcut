import { Controller, Get } from '@nestjs/common'
import { SkipThrottle } from '@nestjs/throttler'
import { HealthCheck, HealthCheckService, PrismaHealthIndicator, MemoryHealthIndicator } from '@nestjs/terminus'
import { PrismaClient } from '@prisma/client'

@SkipThrottle()
@Controller('health')
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly prismaHealth: PrismaHealthIndicator,
    private readonly memoryHealth: MemoryHealthIndicator,
    private readonly prisma: PrismaClient,
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.prismaHealth.pingCheck('database', this.prisma),
      () => this.memoryHealth.checkHeap('memory_heap', 200 * 1024 * 1024),
    ])
  }
}
