import { Module } from '@nestjs/common'
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core'
import { CacheModule } from '@nestjs/cache-manager'
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler'
import { ConfigModule } from './config/config.module'
import { AuthModule } from './auth/auth.module'
import { AdminModule } from './admin/admin.module'
import { HealthModule } from './health/health.module'
import { TransitionsModule } from './transitions/transitions.module'
import { ColorGradesModule } from './color-grades/color-grades.module'
import { CouponsModule } from './coupons/coupons.module'
import { SupportModule } from './support/support.module'
import { NotificationsModule } from './notifications/notifications.module'
import { AnalyticsModule } from './analytics/analytics.module'
import { SettingsModule } from './settings/settings.module'
import { PrismaModule } from './common/prisma.module'
import { RolesGuard } from './common/guards/roles.guard'
import { AppCacheInterceptor } from './common/interceptors/cache.interceptor'

@Module({
  imports: [
    ConfigModule,
    PrismaModule,
    CacheModule.register({ ttl: 60, isGlobal: true }),
    ThrottlerModule.forRoot([
      { name: 'short', ttl: 1000, limit: 10 },
      { name: 'long', ttl: 60000, limit: 100 },
    ]),
    AuthModule,
    AdminModule,
    HealthModule,
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
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_INTERCEPTOR, useClass: AppCacheInterceptor },
  ],
})
export class AppModule {}
