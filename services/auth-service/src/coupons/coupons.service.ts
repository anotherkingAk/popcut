import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common'
import { PrismaClient, DiscountType } from '@prisma/client'

@Injectable()
export class CouponsService {
  constructor(private readonly prisma: PrismaClient) {}

  async list(page = 1, limit = 20) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.prisma.coupon.findMany({ skip, take: limit, orderBy: { createdAt: 'desc' } }),
      this.prisma.coupon.count(),
    ])
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async get(id: string) {
    const item = await this.prisma.coupon.findUnique({ where: { id } })
    if (!item) throw new NotFoundException('Coupon not found')
    return item
  }

  async create(data: any) {
    return this.prisma.coupon.create({ data })
  }

  async update(id: string, data: any) {
    return this.prisma.coupon.update({ where: { id }, data })
  }

  async remove(id: string) {
    await this.prisma.coupon.delete({ where: { id } })
    return { message: 'Coupon deleted' }
  }

  async validate(code: string, amount?: number) {
    const coupon = await this.prisma.coupon.findUnique({ where: { code } })
    if (!coupon) throw new NotFoundException('Coupon not found')
    if (!coupon.active) throw new BadRequestException('Coupon is inactive')
    if (coupon.expiresAt && coupon.expiresAt < new Date()) throw new BadRequestException('Coupon has expired')
    if (coupon.maxUses && coupon.usedCount >= coupon.maxUses) throw new BadRequestException('Coupon usage limit reached')

    let discount = coupon.discountValue
    if (coupon.discountType === DiscountType.PERCENTAGE) {
      discount = amount ? Math.floor(amount * (coupon.discountValue / 100)) : coupon.discountValue
    }

    return { valid: true, coupon, discount }
  }
}
