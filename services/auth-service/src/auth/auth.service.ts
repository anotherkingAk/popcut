import { Injectable, UnauthorizedException, ConflictException, Inject } from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { PrismaClient } from '@prisma/client'
import * as bcrypt from 'bcryptjs'
import type { AppConfig } from '../config/config.module'

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaClient,
    @Inject('APP_CONFIG') private readonly config: AppConfig,
  ) {}

  async register(email: string, password: string, name?: string) {
    const existing = await this.prisma.user.findUnique({ where: { email } })
    if (existing) throw new ConflictException('Email already registered')

    const hashedPassword = await bcrypt.hash(password, 12)
    const user = await this.prisma.user.create({
      data: { email, password: hashedPassword, name },
    })

    return this.generateTokens(user.id, user.email, user.role)
  }

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { email } })
    if (!user) throw new UnauthorizedException('Invalid credentials')

    const valid = await bcrypt.compare(password, user.password)
    if (!valid) throw new UnauthorizedException('Invalid credentials')

    return this.generateTokens(user.id, user.email, user.role)
  }

  async googleAuth(googleToken: string) {
    // Placeholder: integrate with Google OAuth2
    const email = 'google-user@example.com'
    let user = await this.prisma.user.findUnique({ where: { email } })
    if (!user) {
      user = await this.prisma.user.create({
        data: { email, password: '', name: 'Google User' },
      })
    }
    return this.generateTokens(user.id, user.email, user.role)
  }

  async refresh(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken)
      return this.generateTokens(payload.sub, payload.email, payload.role)
    } catch {
      throw new UnauthorizedException('Invalid refresh token')
    }
  }

  async validateUser(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true, name: true, avatar: true, createdAt: true },
    })
  }

  private generateTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role }
    return {
      accessToken: this.jwtService.sign(payload, { expiresIn: '15m' }),
      refreshToken: this.jwtService.sign(payload, { expiresIn: '30d' }),
    }
  }
}
