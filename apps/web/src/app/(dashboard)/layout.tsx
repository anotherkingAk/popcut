import ReactDOM from 'react-dom'
import { Sidebar } from '@/components/layout/Sidebar'
import { TopBar } from '@/components/layout/TopBar'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  ReactDOM.preload('/editor', { as: 'document' })
  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1 ml-16 lg:ml-56">
        <TopBar />
        <main className="p-6">
          {children}
        </main>
      </div>
    </div>
  )
}
