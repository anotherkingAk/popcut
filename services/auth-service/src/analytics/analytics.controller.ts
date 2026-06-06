import { Controller, Get, Query, UseGuards } from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import { RolesGuard } from '../common/guards/roles.guard'
import { Roles } from '../common/decorators/roles.decorator'
import { AnalyticsService } from './analytics.service'

@Controller('admin/analytics')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('ADMIN', 'OWNER')
export class AnalyticsController {
  constructor(private readonly service: AnalyticsService) {}

  @Get('revenue')
  revenue(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.revenue(start, end)
  }

  @Get('dau')
  dailyActiveUsers(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.dailyActiveUsers(start, end)
  }

  @Get('mau')
  monthlyActiveUsers(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.monthlyActiveUsers(start, end)
  }

  @Get('retention')
  retention() {
    return this.service.retention()
  }

  @Get('ai-usage')
  aiUsage(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.aiUsage(start, end)
  }

  @Get('export-usage')
  exportUsage(@Query('start') start?: string, @Query('end') end?: string) {
    return this.service.exportUsage(start, end)
  }

  @Get('popular-templates')
  popularTemplates(@Query('limit') limit?: number) {
    return this.service.popularTemplates(limit || 10)
  }

  @Get('popular-effects')
  popularEffects(@Query('limit') limit?: number) {
    return this.service.popularEffects(limit || 10)
  }

  @Get('storage')
  storage() {
    return this.service.storage()
  }
}
