import { Module } from '@nestjs/common'
import { ConfigModule } from './config/config.module'
import { AuthModule } from './auth/auth.module'
import { PrismaModule } from './common/prisma.module'

@Module({
  imports: [ConfigModule, PrismaModule, AuthModule],
})
export class AppModule {}
