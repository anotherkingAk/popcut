import { CacheInterceptor } from '@nestjs/cache-manager'
import { Injectable, ExecutionContext } from '@nestjs/common'

@Injectable()
export class AppCacheInterceptor extends CacheInterceptor {
  protected isRequestCacheable(context: ExecutionContext): boolean {
    const http = context.switchToHttp()
    const request = http.getRequest()
    const path = request.route?.path || request.url
    // Skip caching for auth and user-specific endpoints
    if (path.includes('/auth/')) return false
    return super.isRequestCacheable(context)
  }
}
