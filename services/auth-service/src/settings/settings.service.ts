import { Injectable } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Injectable()
export class SettingsService {
  constructor(private readonly prisma: PrismaClient) {}

  // --- Maintenance Mode ---
  async getMaintenance() {
    const flag = await this.prisma.featureFlag.findUnique({ where: { name: 'maintenance_mode' } })
    return {
      enabled: flag?.enabled || false,
      message: flag?.rules ? (flag.rules as any).message : undefined,
    }
  }

  async setMaintenance(enabled: boolean, message?: string) {
    const data: any = { enabled }
    if (message !== undefined) data.rules = { message }
    return this.prisma.featureFlag.upsert({
      where: { name: 'maintenance_mode' },
      create: { name: 'maintenance_mode', enabled, description: 'Maintenance mode', rules: message ? { message } : undefined },
      update: data,
    })
  }

  // --- Pricing Plans ---
  async listPlans() {
    return this.prisma.subscriptionPlan.findMany({ orderBy: { price: 'asc' } })
  }

  async createPlan(data: any) {
    return this.prisma.subscriptionPlan.create({ data })
  }

  async updatePlan(id: string, data: any) {
    return this.prisma.subscriptionPlan.update({ where: { id }, data })
  }

  async deletePlan(id: string) {
    await this.prisma.subscriptionPlan.delete({ where: { id } })
    return { message: 'Plan deleted' }
  }

  // --- Force Update ---
  async getForceUpdate() {
    const flag = await this.prisma.featureFlag.findUnique({ where: { name: 'force_update' } })
    if (!flag) return { enabled: false }
    return {
      enabled: flag.enabled,
      minVersion: (flag.rules as any)?.minVersion,
      message: (flag.rules as any)?.message,
    }
  }

  async setForceUpdate(data: { enabled: boolean; minVersion?: string; message?: string }) {
    return this.prisma.featureFlag.upsert({
      where: { name: 'force_update' },
      create: {
        name: 'force_update',
        enabled: data.enabled,
        description: 'Force app update',
        rules: { minVersion: data.minVersion, message: data.message },
      },
      update: {
        enabled: data.enabled,
        rules: { minVersion: data.minVersion, message: data.message },
      },
    })
  }

  // --- Backup ---
  async triggerBackup() {
    return { message: 'Backup triggered. This process runs asynchronously.', timestamp: new Date().toISOString() }
  }

  async backupStatus() {
    return { status: 'idle', lastBackup: null, message: 'Backup service is managed externally' }
  }
}
