import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import { RolesGuard } from '../common/guards/roles.guard'
import { Roles } from '../common/decorators/roles.decorator'
import { CouponsService } from './coupons.service'

@Controller('admin/coupons')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('ADMIN', 'OWNER')
export class CouponsController {
  constructor(private readonly service: CouponsService) {}

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

  @Post('validate')
  validate(@Body() body: { code: string; amount?: number }) {
    return this.service.validate(body.code, body.amount)
  }
}
