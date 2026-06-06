import { Injectable, NotFoundException } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaClient) {}

  async list(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.notification.findMany({
        skip, take: limit, orderBy: { createdAt: 'desc' },
        include: { user: { select: { id: true, email: true, name: true } } },
      }),
      this.prisma.notification.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async get(id: string) {
    const item = await this.prisma.notification.findUnique({
      where: { id },
      include: { user: { select: { id: true, email: true, name: true } } },
    })
    if (!item) throw new NotFoundException('Notification not found')
    return item
  }

  async create(data: { userId: string; type?: string; title: string; body: string; data?: any }) {
    return this.prisma.notification.create({ data: data as any })
  }

  async update(id: string, data: any) {
    await this.get(id)
    return this.prisma.notification.update({ where: { id }, data })
  }

  async remove(id: string) {
    await this.get(id)
    await this.prisma.notification.delete({ where: { id } })
    return { message: 'Notification deleted' }
  }

  async markRead(id: string) {
    await this.get(id)
    return this.prisma.notification.update({ where: { id }, data: { read: true } })
  }

  async broadcast(data: { type: string; title: string; body: string; data?: any }) {
    let cursor: string | undefined
    const batchSize = 1000
    let total = 0
    while (true) {
      const users = await this.prisma.user.findMany({
        take: batchSize,
        ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
        select: { id: true },
        orderBy: { id: 'asc' },
      })
      if (users.length === 0) break
      await this.prisma.notification.createMany({
        data: users.map(u => ({
          userId: u.id,
          type: data.type as any,
          title: data.title,
          body: data.body,
          data: data.data,
        })),
      })
      total += users.length
      cursor = users[users.length - 1].id
    }
    return { message: `Broadcast sent to ${total} users` }
  }
}
