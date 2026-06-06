import { Module, Global, Logger } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Global()
@Module({
  providers: [
    {
      provide: PrismaClient,
      useFactory: () => {
        const logger = new Logger('Prisma')
        const url = new URL(process.env.DATABASE_URL || 'postgresql://popcut:popcut@localhost:5432/popcut')
        url.searchParams.set('connection_limit', '20')
        url.searchParams.set('pool_timeout', '10')
        const client = new PrismaClient({
          datasources: { db: { url: url.toString() } },
          log: [
            { level: 'warn', emit: 'event' },
            { level: 'error', emit: 'event' },
          ],
        })
        client.$on('query' as never, (e: any) => {
          if (e.duration > 1000) {
            logger.warn(`Slow query (${e.duration}ms): ${e.query}`)
          }
        })
        return client
      },
    },
  ],
  exports: [PrismaClient],
})
export class PrismaModule {}
