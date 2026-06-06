import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Injectable()
export class SupportService {
  constructor(private readonly prisma: PrismaClient) {}

  async list(page = 1, limit = 20, status?: string) {
    const skip = (page - 1) * limit
    const where = status ? { status } : {}
    const [data, total] = await Promise.all([
      this.prisma.supportTicket.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        where,
        include: { user: { select: { id: true, email: true, name: true } } },
      }),
      this.prisma.supportTicket.count({ where }),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async get(id: string) {
    const ticket = await this.prisma.supportTicket.findUnique({
      where: { id },
      include: { user: { select: { id: true, email: true, name: true } } },
    })
    if (!ticket) throw new NotFoundException('Support ticket not found')
    return ticket
  }

  async update(id: string, data: any) {
    return this.prisma.supportTicket.update({ where: { id }, data })
  }

  async remove(id: string) {
    await this.prisma.supportTicket.delete({ where: { id } })
    return { message: 'Support ticket deleted' }
  }

  async assign(id: string, assignedTo: string) {
    return this.prisma.supportTicket.update({ where: { id }, data: { assignedTo } })
  }

  async resolve(id: string) {
    return this.prisma.supportTicket.update({
      where: { id },
      data: { status: 'resolved', resolvedAt: new Date() },
    })
  }
}
