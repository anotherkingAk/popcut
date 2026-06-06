import { Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { ColorGradesController } from './color-grades.controller'
import { ColorGradesService } from './color-grades.service'

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
  controllers: [ColorGradesController],
  providers: [ColorGradesService],
})
export class ColorGradesModule {}
