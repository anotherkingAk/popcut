import { Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { SupportController } from './support.controller'
import { SupportService } from './support.service'

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      useFactory: () => ({
        secret: process.env.JWT_SECRET || 'popcut-dev-secret-change-in-production',
        signOptions: { expiresIn: '7d' as any },
      }),
    }),
  ],
  controllers: [SupportController],
  providers: [SupportService],
})
export class SupportModule {}
