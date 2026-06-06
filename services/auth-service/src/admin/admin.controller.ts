import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import { RolesGuard } from '../common/guards/roles.guard'
import { Roles } from '../common/decorators/roles.decorator'
import { AdminService } from './admin.service'

@Controller('admin')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('ADMIN', 'OWNER')
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  // --- Dashboard ---
  @Get('dashboard')
  getDashboard() {
    return this.admin.getDashboard()
  }

  // --- Users ---
  @Get('users')
  listUsers(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listUsers(page || 1, limit || 20)
  }

  @Get('users/:id')
  getUser(@Param('id') id: string) {
    return this.admin.getUser(id)
  }

  @Put('users/:id')
  updateUser(@Param('id') id: string, @Body() body: any) {
    return this.admin.updateUser(id, body)
  }

  @Delete('users/:id')
  deleteUser(@Param('id') id: string) {
    return this.admin.deleteUser(id)
  }

  // --- Projects ---
  @Get('projects')
  listProjects(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listProjects(page || 1, limit || 20)
  }

  @Delete('projects/:id')
  deleteProject(@Param('id') id: string) {
    return this.admin.deleteProject(id)
  }

  // --- Templates ---
  @Get('templates')
  listTemplates(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listTemplates(page || 1, limit || 20)
  }

  @Post('templates')
  createTemplate(@Body() body: any) {
    return this.admin.createTemplate(body)
  }

  @Put('templates/:id')
  updateTemplate(@Param('id') id: string, @Body() body: any) {
    return this.admin.updateTemplate(id, body)
  }

  @Delete('templates/:id')
  deleteTemplate(@Param('id') id: string) {
    return this.admin.deleteTemplate(id)
  }

  // --- Effects ---
  @Get('effects')
  listEffects(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listEffects(page || 1, limit || 20)
  }

  @Post('effects')
  createEffect(@Body() body: any) {
    return this.admin.createEffect(body)
  }

  @Put('effects/:id')
  updateEffect(@Param('id') id: string, @Body() body: any) {
    return this.admin.updateEffect(id, body)
  }

  @Delete('effects/:id')
  deleteEffect(@Param('id') id: string) {
    return this.admin.deleteEffect(id)
  }

  // --- Filters ---
  @Get('filters')
  listFilters(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listFilters(page || 1, limit || 20)
  }

  @Post('filters')
  createFilter(@Body() body: any) {
    return this.admin.createFilter(body)
  }

  @Put('filters/:id')
  updateFilter(@Param('id') id: string, @Body() body: any) {
    return this.admin.updateFilter(id, body)
  }

  @Delete('filters/:id')
  deleteFilter(@Param('id') id: string) {
    return this.admin.deleteFilter(id)
  }

  // --- Fonts ---
  @Get('fonts')
  listFonts(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listFonts(page || 1, limit || 20)
  }

  @Post('fonts')
  createFont(@Body() body: any) {
    return this.admin.createFont(body)
  }

  @Put('fonts/:id')
  updateFont(@Param('id') id: string, @Body() body: any) {
    return this.admin.updateFont(id, body)
  }

  @Delete('fonts/:id')
  deleteFont(@Param('id') id: string) {
    return this.admin.deleteFont(id)
  }

  // --- Audio ---
  @Get('audio')
  listAudio(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listAudio(page || 1, limit || 20)
  }

  @Post('audio')
  createAudio(@Body() body: any) {
    return this.admin.createAudio(body)
  }

  @Put('audio/:id')
  updateAudio(@Param('id') id: string, @Body() body: any) {
    return this.admin.updateAudio(id, body)
  }

  @Delete('audio/:id')
  deleteAudio(@Param('id') id: string) {
    return this.admin.deleteAudio(id)
  }

  // --- Subscriptions ---
  @Get('subscriptions')
  listSubscriptions(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listSubscriptions(page || 1, limit || 20)
  }

  @Put('subscriptions/:id')
  updateSubscription(@Param('id') id: string, @Body() body: any) {
    return this.admin.updateSubscription(id, body)
  }

  // --- AI Jobs ---
  @Get('ai-jobs')
  listAIJobs(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listAIJobs(page || 1, limit || 20)
  }

  @Post('ai-jobs/:id/retry')
  retryAIJob(@Param('id') id: string) {
    return this.admin.retryAIJob(id)
  }

  // --- Export Jobs ---
  @Get('export-jobs')
  listExportJobs(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listExportJobs(page || 1, limit || 20)
  }

  // --- Audit Logs ---
  @Get('audit-logs')
  listAuditLogs(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listAuditLogs(page || 1, limit || 50)
  }

  // --- Feature Flags ---
  @Get('feature-flags')
  listFeatureFlags() {
    return this.admin.listFeatureFlags()
  }

  @Post('feature-flags')
  createFeatureFlag(@Body() body: any) {
    return this.admin.createFeatureFlag(body)
  }

  @Put('feature-flags/:id')
  updateFeatureFlag(@Param('id') id: string, @Body() body: any) {
    return this.admin.updateFeatureFlag(id, body)
  }

  @Delete('feature-flags/:id')
  deleteFeatureFlag(@Param('id') id: string) {
    return this.admin.deleteFeatureFlag(id)
  }

  // --- Credit Transactions ---
  @Get('credit-transactions')
  listCreditTransactions(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.admin.listCreditTransactions(page || 1, limit || 20)
  }

  @Post('credit-transactions')
  createCreditTransaction(@Body() body: any) {
    return this.admin.createCreditTransaction(body)
  }
}
