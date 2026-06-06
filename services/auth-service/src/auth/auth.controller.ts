import { Controller, Post, Get, Body, UseGuards, Req } from '@nestjs/common'
import { Throttle } from '@nestjs/throttler'
import { AuthGuard } from '@nestjs/passport'
import { AuthService } from './auth.service'
import { RegisterDto, LoginDto, GoogleAuthDto, RefreshDto } from './dto'

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto.email, dto.password, dto.name)
  }

  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto.email, dto.password)
  }

  @Post('google')
  googleAuth(@Body() dto: GoogleAuthDto) {
    return this.authService.googleAuth(dto.token)
  }

  @Post('refresh')
  refresh(@Body() dto: RefreshDto) {
    return this.authService.refresh(dto.refreshToken)
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('me')
  getMe(@Req() req: { user: unknown }) {
    return req.user
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('logout')
  logout() {
    return { message: 'Logged out successfully' }
  }
}
