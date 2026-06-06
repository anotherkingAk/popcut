import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import { RolesGuard } from '../common/guards/roles.guard'
import { Roles } from '../common/decorators/roles.decorator'
import { ColorGradesService } from './color-grades.service'

@Controller('admin/color-grades')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('ADMIN', 'OWNER')
export class ColorGradesController {
  constructor(private readonly service: ColorGradesService) {}

  @Get()
  list(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.service.list(page || 1, limit || 20)
  }

  @Get(':id')
  get(@Param('id') id: string) {
    return this.service.get(id)
  }

  @Post()
  create(@Body() body: any) {
    return this.service.create(body)
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: any) {
    return this.service.update(id, body)
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id)
  }

  @Post(':id/publish')
  publish(@Param('id') id: string) {
    return this.service.update(id, { isPublic: true })
  }

  @Post(':id/unpublish')
  unpublish(@Param('id') id: string) {
    return this.service.update(id, { isPublic: false })
  }
}
