import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import { RolesGuard } from '../common/guards/roles.guard'
import { Roles } from '../common/decorators/roles.decorator'
import { SupportService } from './support.service'

@Controller('admin/support')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('ADMIN', 'OWNER')
export class SupportController {
  constructor(private readonly service: SupportService) {}

  @Get()
  list(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
  ) {
    return this.service.list(page || 1, limit || 20, status)
  }

  @Get(':id')
  get(@Param('id') id: string) {
    return this.service.get(id)
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: any) {
    return this.service.update(id, body)
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id)
  }

  @Post(':id/assign')
  assign(@Param('id') id: string, @Body() body: { assignedTo: string }) {
    return this.service.assign(id, body.assignedTo)
  }

  @Post(':id/resolve')
  resolve(@Param('id') id: string) {
    return this.service.resolve(id)
  }
}
