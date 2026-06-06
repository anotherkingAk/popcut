import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common'
import { CacheTTL } from '@nestjs/cache-manager'
import { AuthGuard } from '@nestjs/passport'
import { RolesGuard } from '../common/guards/roles.guard'
import { Roles } from '../common/decorators/roles.decorator'
import { SettingsService } from './settings.service'

@Controller('admin/settings')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('OWNER')
export class SettingsController {
  constructor(private readonly service: SettingsService) {}

  // --- Maintenance Mode ---
  @CacheTTL(60)
  @Get('maintenance')
  getMaintenance() {
    return this.service.getMaintenance()
  }

  @Put('maintenance')
  setMaintenance(@Body() body: { enabled: boolean; message?: string }) {
    return this.service.setMaintenance(body.enabled, body.message)
  }

  // --- Pricing Plans ---
  @CacheTTL(60)
  @Get('pricing')
  listPlans() {
    return this.service.listPlans()
  }

  @Post('pricing')
  createPlan(@Body() body: any) {
    return this.service.createPlan(body)
  }

  @Put('pricing/:id')
  updatePlan(@Param('id') id: string, @Body() body: any) {
    return this.service.updatePlan(id, body)
  }

  @Delete('pricing/:id')
  deletePlan(@Param('id') id: string) {
    return this.service.deletePlan(id)
  }

  // --- Force Update ---
  @CacheTTL(60)
  @Get('force-update')
  getForceUpdate() {
    return this.service.getForceUpdate()
  }

  @Put('force-update')
  setForceUpdate(@Body() body: { enabled: boolean; minVersion?: string; message?: string }) {
    return this.service.setForceUpdate(body)
  }

  // --- Backup ---
  @Post('backup')
  triggerBackup() {
    return this.service.triggerBackup()
  }

  @CacheTTL(60)
  @Get('backup/status')
  backupStatus() {
    return this.service.backupStatus()
  }
}
