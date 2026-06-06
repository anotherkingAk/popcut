import { Module, Global } from '@nestjs/common'

export interface AppConfig {
  jwtSecret: string
  jwtExpiresIn: string
  databaseUrl: string
  port: number
}

@Global()
@Module({
  providers: [
    {
      provide: 'APP_CONFIG',
      useFactory: (): AppConfig => ({
        jwtSecret: process.env.JWT_SECRET || 'popcut-dev-secret-change-in-production',
        jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
        databaseUrl: process.env.DATABASE_URL || 'postgresql://popcut:popcut@localhost:5432/popcut',
        port: parseInt(process.env.PORT || '4001', 10),
      }),
    },
  ],
  exports: ['APP_CONFIG'],
})
export class ConfigModule {}
