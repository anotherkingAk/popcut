import axios, { type AxiosInstance, type AxiosRequestConfig } from 'axios'

export interface AuthTokens {
  accessToken: string
  refreshToken: string
}

export interface AuthUser {
  id: string
  email: string
  name?: string
  avatar?: string
}

export class PopCutAPI {
  private client: AxiosInstance
  private tokens: AuthTokens | null = null

  constructor(baseURL: string = 'http://localhost:4001') {
    this.client = axios.create({
      baseURL,
      timeout: 30000,
      headers: { 'Content-Type': 'application/json' },
    })

    this.client.interceptors.request.use(config => {
      if (this.tokens?.accessToken) {
        config.headers.Authorization = `Bearer ${this.tokens.accessToken}`
      }
      return config
    })

    this.client.interceptors.response.use(
      res => res,
      async err => {
        if (err.response?.status === 401 && this.tokens?.refreshToken) {
          try {
            const { data } = await axios.post(`${baseURL}/api/v1/auth/refresh`, {
              refreshToken: this.tokens.refreshToken,
            })
            this.setTokens(data)
            err.config.headers.Authorization = `Bearer ${data.accessToken}`
            return this.client(err.config)
          } catch {
            this.clearTokens()
          }
        }
        return Promise.reject(err)
      }
    )
  }

  setTokens(tokens: AuthTokens): void {
    this.tokens = tokens
  }

  clearTokens(): void {
    this.tokens = null
  }

  isAuthenticated(): boolean {
    return this.tokens !== null
  }

  async authWithEmail(email: string, password: string): Promise<AuthTokens> {
    const { data } = await this.client.post('/api/v1/auth/login', { email, password })
    this.setTokens(data)
    return data
  }

  async register(email: string, password: string, name?: string): Promise<AuthTokens> {
    const { data } = await this.client.post('/api/v1/auth/register', { email, password, name })
    this.setTokens(data)
    return data
  }

  async authWithGoogle(token: string): Promise<AuthTokens> {
    const { data } = await this.client.post('/api/v1/auth/google', { token })
    this.setTokens(data)
    return data
  }

  async logout(): Promise<void> {
    await this.client.post('/api/v1/auth/logout')
    this.clearTokens()
  }

  async getMe(): Promise<AuthUser> {
    const { data } = await this.client.get('/api/v1/auth/me')
    return data
  }

  get<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.client.get(url, config).then(r => r.data)
  }

  post<T = unknown>(url: string, body?: unknown, config?: AxiosRequestConfig): Promise<T> {
    return this.client.post(url, body, config).then(r => r.data)
  }

  put<T = unknown>(url: string, body?: unknown, config?: AxiosRequestConfig): Promise<T> {
    return this.client.put(url, body, config).then(r => r.data)
  }

  delete<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.client.delete(url, config).then(r => r.data)
  }
}

export const api = new PopCutAPI()
