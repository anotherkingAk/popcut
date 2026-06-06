import { Module } from '@nestjs/common'
import { APP_GUARD } from '@nestjs/core'
import { ConfigModule } from './config/config.module'
import { AuthModule } from './auth/auth.module'
import { AdminModule } from './admin/admin.module'
import { TransitionsModule } from './transitions/transitions.module'
import { ColorGradesModule } from './color-grades/color-grades.module'
import { CouponsModule } from './coupons/coupons.module'
import { SupportModule } from './support/support.module'
import { NotificationsModule } from './notifications/notifications.module'
import { AnalyticsModule } from './analytics/analytics.module'
import { SettingsModule } from './settings/settings.module'
import { PrismaModule } from './common/prisma.module'
import { RolesGuard } from './common/guards/roles.guard'

@Module({
  imports: [
    ConfigModule,
    PrismaModule,
    AuthModule,
    AdminModule,
    TransitionsModule,
    ColorGradesModule,
    CouponsModule,
    SupportModule,
    NotificationsModule,
    AnalyticsModule,
    SettingsModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
