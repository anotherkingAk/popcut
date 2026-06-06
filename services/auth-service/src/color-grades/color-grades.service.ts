import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Injectable()
export class ColorGradesService {
  constructor(private readonly prisma: PrismaClient) {}

  async list(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.colorGrade.findMany({ skip, take: limit, orderBy: { createdAt: 'desc' } }),
      this.prisma.colorGrade.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async get(id: string) {
    const item = await this.prisma.colorGrade.findUnique({ where: { id } })
    if (!item) throw new NotFoundException('Color grade not found')
    return item
  }

  async create(data: any) {
    return this.prisma.colorGrade.create({ data })
  }

  async update(id: string, data: any) {
    return this.prisma.colorGrade.update({ where: { id }, data })
  }

  async remove(id: string) {
    await this.prisma.colorGrade.delete({ where: { id } })
    return { message: 'Color grade deleted' }
  }
}
