import { JwtService } from '@nestjs/jwt'
import { ConflictException, UnauthorizedException } from '@nestjs/common'
import { AuthService } from './auth.service'

vi.mock('bcryptjs', () => ({
  hash: vi.fn(() => Promise.resolve('hashed-password')),
  compare: vi.fn(() => Promise.resolve(true)),
}))

import * as bcrypt from 'bcryptjs'

const mockPrisma = {
  user: { findUnique: vi.fn(), create: vi.fn() },
}

describe('AuthService', () => {
  let service: AuthService

  beforeEach(() => {
    vi.clearAllMocks()
    const jwtService = new JwtService({ secret: 'test-secret', signOptions: { expiresIn: '15m' } })
    service = new AuthService(jwtService, mockPrisma as any, { jwtSecret: 'test-secret', jwtExpiresIn: '15m' } as any)
  })

  describe('register', () => {
    it('should register a new user and return tokens', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(null)
      mockPrisma.user.create.mockResolvedValue({ id: 'user-1', email: 'test@example.com', role: 'USER' })

      const result = await service.register('test@example.com', 'password123', 'Test User')

      expect(mockPrisma.user.findUnique).toHaveBeenCalledWith({ where: { email: 'test@example.com' } })
      expect(mockPrisma.user.create).toHaveBeenCalledWith({
        data: { email: 'test@example.com', password: 'hashed-password', name: 'Test User' },
      })
      expect(result).toHaveProperty('accessToken')
      expect(result).toHaveProperty('refreshToken')
    })

    it('should throw ConflictException if email already exists', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'existing', email: 'test@example.com' })

      await expect(service.register('test@example.com', 'password123')).rejects.toThrow(ConflictException)
      expect(mockPrisma.user.create).not.toHaveBeenCalled()
    })
  })

  describe('login', () => {
    it('should login and return tokens', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'user-1', email: 'test@example.com', role: 'USER', password: 'hashed-password' })

      const result = await service.login('test@example.com', 'password123')

      expect(mockPrisma.user.findUnique).toHaveBeenCalledWith({ where: { email: 'test@example.com' } })
      expect(result).toHaveProperty('accessToken')
      expect(result).toHaveProperty('refreshToken')
    })

    it('should throw UnauthorizedException if user not found', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(null)
      await expect(service.login('nonexistent@example.com', 'password')).rejects.toThrow(UnauthorizedException)
    })

    it('should throw UnauthorizedException if password is invalid', async () => {
      ;(bcrypt.compare as any).mockResolvedValueOnce(false)
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'user-1', email: 'test@example.com', password: 'hashed-password', role: 'USER' })
      await expect(service.login('test@example.com', 'wrong-password')).rejects.toThrow(UnauthorizedException)
    })
  })

  describe('validateUser', () => {
    it('should return user data without password', async () => {
      const mockUser = { id: 'user-1', email: 'test@example.com', name: 'Test', avatar: null, createdAt: new Date() }
      mockPrisma.user.findUnique.mockResolvedValue(mockUser)

      const result = await service.validateUser('user-1')

      expect(mockPrisma.user.findUnique).toHaveBeenCalledWith({
        where: { id: 'user-1' },
        select: { id: true, email: true, name: true, avatar: true, createdAt: true },
      })
      expect(result).toEqual(mockUser)
    })

    it('should return null if user not found', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(null)
      expect(await service.validateUser('nonexistent')).toBeNull()
    })
  })

  describe('refresh', () => {
    it('should return new tokens with valid refresh token', async () => {
      const jwtService = new JwtService({ secret: 'test-secret' })
      const validToken = jwtService.sign({ sub: 'user-1', email: 'test@example.com', role: 'USER' })
      const result = await service.refresh(validToken)
      expect(result).toHaveProperty('accessToken')
      expect(result).toHaveProperty('refreshToken')
    })

    it('should throw UnauthorizedException with invalid refresh token', async () => {
      await expect(service.refresh('invalid-token')).rejects.toThrow(UnauthorizedException)
    })
  })

  describe('googleAuth', () => {
    it('should login existing google user', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'user-1', email: 'google-user@example.com', role: 'USER' })
      const result = await service.googleAuth('google-token')
      expect(mockPrisma.user.create).not.toHaveBeenCalled()
      expect(result).toHaveProperty('accessToken')
      expect(result).toHaveProperty('refreshToken')
    })

    it('should create and login new google user', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(null)
      mockPrisma.user.create.mockResolvedValue({ id: 'user-1', email: 'google-user@example.com', role: 'USER' })
      const result = await service.googleAuth('google-token')
      expect(mockPrisma.user.create).toHaveBeenCalledWith({
        data: { email: 'google-user@example.com', password: '', name: 'Google User' },
      })
      expect(result).toHaveProperty('accessToken')
      expect(result).toHaveProperty('refreshToken')
    })
  })
})
