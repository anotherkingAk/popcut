import { Controller, Get, Query, UseGuards } from '@nestjs/common'
import { CacheTTL } from '@nestjs/cache-manager'
import { AuthGuard } from '@nestjs/passport'
import { RolesGuard } from '../common/guards/roles.guard'
import { Roles } from '../common/decorators/roles.decorator'
import { AnalyticsService } from './analytics.service'

@Controller('admin/analytics')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('ADMIN', 'OWNER')
export class AnalyticsController {
  constructor(private readonly service: AnalyticsService) {}

  @CacheTTL(300)
  @Get('revenue')
  revenue(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.revenue(start, end)
  }

  @CacheTTL(300)
  @Get('dau')
  dailyActiveUsers(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.dailyActiveUsers(start, end)
  }

  @CacheTTL(300)
  @Get('mau')
  monthlyActiveUsers(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.monthlyActiveUsers(start, end)
  }

  @CacheTTL(300)
  @Get('retention')
  retention() {
    return this.service.retention()
  }

  @CacheTTL(300)
  @Get('ai-usage')
  aiUsage(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.aiUsage(start, end)
  }

  @CacheTTL(300)
  @Get('export-usage')
  exportUsage(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.exportUsage(start, end)
  }

  @CacheTTL(60)
  @Get('popular-templates')
  popularTemplates(@Query('limit') limit?: number) {
    return this.service.popularTemplates(limit || 10)
  }

  @CacheTTL(60)
  @Get('popular-effects')
  popularEffects(@Query('limit') limit?: number) {
    return this.service.popularEffects(limit || 10)
  }

  @CacheTTL(60)
  @Get('storage')
  storage() {
    return this.service.storage()
  }
}
