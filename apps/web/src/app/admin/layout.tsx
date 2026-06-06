'use client'

import { AdminSidebar } from '@/components/admin/AdminSidebar'
import { AdminHeader } from '@/components/admin/AdminHeader'
import { useAdminUI } from '@/stores/admin-ui'
import { cn } from '@/lib/utils'

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { sidebarOpen } = useAdminUI()

  return (
    <div className="flex min-h-screen bg-background">
      <AdminSidebar />
      <div
        className={cn(
          'flex-1 flex flex-col transition-all duration-200',
          'lg:ml-56',
          !sidebarOpen && 'lg:ml-16'
        )}
      >
        <AdminHeader />
        <main className="flex-1 p-4 lg:p-6 overflow-auto">
          {children}
        </main>
      </div>
    </div>
  )
}
