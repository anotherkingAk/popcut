import { Module } from '@nestjs/common'
import { APP_GUARD } from '@nestjs/core'
import { ConfigModule } from './config/config.module'
import { AuthModule } from './auth/auth.module'
import { AdminModule } from './admin/admin.module'
import { PrismaModule } from './common/prisma.module'
import { RolesGuard } from './common/guards/roles.guard'

@Module({
  imports: [ConfigModule, PrismaModule, AuthModule, AdminModule],
  providers: [
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
