'use client'

import { useState } from 'react'
import {
  useCreditPackages, useCreditTransactions, useCreateCreditPackage,
  useUpdateCreditPackage, useTogglePackageActive,
} from '@/hooks/admin/useAdminSubscriptions'
import { DataTable } from '@/components/admin/DataTable'
import { PageHeader } from '@/components/admin/PageHeader'
import { StatusBadge } from '@/components/admin/StatusBadge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { type ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import type { CreditPackage, CreditTransaction } from '@/types/admin'
import { Coins, Plus, Check, X } from 'lucide-react'
import { Switch } from '@radix-ui/react-switch'

export default function CreditsPage() {
  const [page, setPage] = useState(0)
  const [showPackageDialog, setShowPackageDialog] = useState(false)
  const [editPackage, setEditPackage] = useState<CreditPackage | null>(null)
  const [pkgName, setPkgName] = useState('')
  const [pkgCredits, setPkgCredits] = useState('')
  const [pkgPrice, setPkgPrice] = useState('')

  const { data: packages, isLoading: packagesLoading } = useCreditPackages()
  const { data: transactions, isLoading: txLoading } = useCreditTransactions(page + 1)
  const createPackage = useCreateCreditPackage()
  const updatePackage = useUpdateCreditPackage()
  const toggleActive = useTogglePackageActive()

  const txnColumns: ColumnDef<CreditTransaction>[] = [
    {
      accessorKey: 'userName',
      header: 'User',
      cell: ({ row }) => <span className="font-medium text-text">{row.original.userName}</span>,
    },
    {
      accessorKey: 'type',
      header: 'Type',
      cell: ({ row }) => <StatusBadge status={row.original.type} />,
    },
    {
      accessorKey: 'amount',
      header: 'Amount',
      cell: ({ row }) => (
        <span className={row.original.amount > 0 ? 'text-success' : 'text-danger'}>
          {row.original.amount > 0 ? '+' : ''}{row.original.amount}
        </span>
      ),
    },
    {
      accessorKey: 'balance',
      header: 'Balance',
      cell: ({ row }) => <span>{row.original.balance.toLocaleString()}</span>,
    },
    {
      accessorKey: 'description',
      header: 'Description',
      cell: ({ row }) => <span className="text-text-secondary text-sm">{row.original.description}</span>,
    },
    {
      accessorKey: 'createdAt',
      header: 'Date',
      cell: ({ row }) => (
        <span className="text-text-muted text-xs">
          {format(new Date(row.original.createdAt), 'MMM d, HH:mm')}
        </span>
      ),
    },
  ]

  const handleSavePackage = () => {
    const data = { name: pkgName, credits: parseInt(pkgCredits), price: parseFloat(pkgPrice) }
    if (editPackage) {
      updatePackage.mutate({ id: editPackage.id, data })
    } else {
      createPackage.mutate(data)
    }
    setShowPackageDialog(false)
    setEditPackage(null)
    setPkgName('')
    setPkgCredits('')
    setPkgPrice('')
  }

  const openNewPackage = () => {
    setEditPackage(null)
    setPkgName('')
    setPkgCredits('')
    setPkgPrice('')
    setShowPackageDialog(true)
  }

  return (
    <div>
      <PageHeader
        title="Credits"
        description="Manage credit packages and transaction history"
        actions={
          <Button onClick={openNewPackage}>
            <Plus className="h-4 w-4 mr-2" />
            Add Package
          </Button>
        }
      />

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {packages?.map((pkg) => (
          <div
            key={pkg.id}
            className={`rounded-xl border p-5 ${
              pkg.popular
                ? 'border-primary bg-primary/5'
                : 'border-border bg-surface'
            }`}
          >
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-semibold text-text">{pkg.name}</h3>
              <div className="flex items-center gap-2">
                <Switch
                  checked={pkg.active}
                  onCheckedChange={() => toggleActive.mutate(pkg.id)}
                  className="data-[state=checked]:bg-primary data-[state=unchecked]:bg-border h-5 w-9 rounded-full relative"
                >
                  <span className="data-[state=checked]:translate-x-4 data-[state=unchecked]:translate-x-0.5 block h-4 w-4 rounded-full bg-white transition-transform" />
                </Switch>
              </div>
            </div>
            <p className="text-2xl font-bold text-text mb-1">
              {pkg.credits.toLocaleString()} <span className="text-sm font-normal text-text-muted">credits</span>
            </p>
            <p className="text-lg text-primary font-semibold">${pkg.price.toFixed(2)}</p>
            <div className="flex gap-2 mt-3">
              {pkg.popular && (
                <span className="inline-flex items-center gap-1 text-xs text-primary">
                  <Check className="h-3 w-3" /> Popular
                </span>
              )}
              {!pkg.active && (
                <span className="text-xs text-text-muted">Inactive</span>
              )}
            </div>
          </div>
        ))}
      </div>

      <h2 className="text-lg font-semibold text-text mb-4">Transaction History</h2>
      <DataTable
        columns={txnColumns}
        data={transactions?.data ?? []}
        pageCount={transactions?.totalPages}
        pageIndex={page}
        onPageChange={setPage}
        loading={txLoading}
      />

      <Dialog open={showPackageDialog} onOpenChange={setShowPackageDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{editPackage ? 'Edit Package' : 'New Credit Package'}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Package Name</label>
              <Input value={pkgName} onChange={(e) => setPkgName(e.target.value)} placeholder="e.g. Starter" />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Credits</label>
              <Input type="number" value={pkgCredits} onChange={(e) => setPkgCredits(e.target.value)} placeholder="100" />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Price ($)</label>
              <Input type="number" step="0.01" value={pkgPrice} onChange={(e) => setPkgPrice(e.target.value)} placeholder="9.99" />
            </div>
            <Button className="w-full" onClick={handleSavePackage} disabled={!pkgName || !pkgCredits || !pkgPrice}>
              {editPackage ? 'Update' : 'Create'} Package
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
