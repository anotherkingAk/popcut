'use client'

import { useState } from 'react'
import { useAppSettings, useUpdateAppSettings, useFeatureFlags, useToggleFeatureFlag, useCreateFeatureFlag } from '@/hooks/admin/useAdminSettings'
import { PageHeader } from '@/components/admin/PageHeader'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Switch } from '@radix-ui/react-switch'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { toast } from 'sonner'
import { Plus, Flag, Settings2 } from 'lucide-react'

export default function SettingsPage() {
  const { data: settings, isLoading: settingsLoading } = useAppSettings()
  const { data: flags } = useFeatureFlags()
  const updateSettings = useUpdateAppSettings()
  const toggleFlag = useToggleFeatureFlag()
  const createFlag = useCreateFeatureFlag()

  const [maintenanceMode, setMaintenanceMode] = useState(false)
  const [maintenanceMessage, setMaintenanceMessage] = useState('')
  const [forceUpdate, setForceUpdate] = useState(false)
  const [minVersion, setMinVersion] = useState('')
  const [latestVersion, setLatestVersion] = useState('')
  const [updateUrl, setUpdateUrl] = useState('')
  const [maxUpload, setMaxUpload] = useState('')
  const [defaultCredits, setDefaultCredits] = useState('')
  const [trialDays, setTrialDays] = useState('')
  const [showNewFlag, setShowNewFlag] = useState(false)
  const [newFlagKey, setNewFlagKey] = useState('')
  const [newFlagName, setNewFlagName] = useState('')
  const [newFlagDesc, setNewFlagDesc] = useState('')

  useState(() => {
    if (settings) {
      setMaintenanceMode(settings.maintenanceMode)
      setMaintenanceMessage(settings.maintenanceMessage)
      setForceUpdate(settings.forceUpdate)
      setMinVersion(settings.minimumAppVersion)
      setLatestVersion(settings.latestAppVersion)
      setUpdateUrl(settings.updateUrl)
      setMaxUpload(String(settings.maxUploadSize))
      setDefaultCredits(String(settings.defaultCredits))
      setTrialDays(String(settings.trialDays))
    }
  })

  const handleSaveSettings = () => {
    updateSettings.mutate({
      maintenanceMode,
      maintenanceMessage,
      forceUpdate,
      minimumAppVersion: minVersion,
      latestAppVersion: latestVersion,
      updateUrl,
      maxUploadSize: parseInt(maxUpload),
      defaultCredits: parseInt(defaultCredits),
      trialDays: parseInt(trialDays),
    })
  }

  const handleCreateFlag = () => {
    createFlag.mutate({
      key: newFlagKey,
      name: newFlagName,
      description: newFlagDesc,
      enabled: false,
      percentage: 0,
    })
    setShowNewFlag(false)
    setNewFlagKey('')
    setNewFlagName('')
    setNewFlagDesc('')
  }

  if (settingsLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin h-8 w-8 rounded-full border-2 border-primary border-t-transparent" />
      </div>
    )
  }

  return (
    <div>
      <PageHeader title="Settings" description="System configuration and feature flags" />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="rounded-xl border border-border bg-surface p-6">
          <div className="flex items-center gap-2 mb-5">
            <Settings2 className="h-5 w-5 text-primary" />
            <h2 className="text-lg font-semibold text-text">System Settings</h2>
          </div>
          <div className="space-y-5">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-text">Maintenance Mode</p>
                <p className="text-xs text-text-muted">Block user access with a message</p>
              </div>
              <Switch
                checked={maintenanceMode}
                onCheckedChange={setMaintenanceMode}
                className="data-[state=checked]:bg-danger data-[state=unchecked]:bg-border h-5 w-9 rounded-full relative"
              >
                <span className="data-[state=checked]:translate-x-4 data-[state=unchecked]:translate-x-0.5 block h-4 w-4 rounded-full bg-white transition-transform" />
              </Switch>
            </div>

            {maintenanceMode && (
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-secondary">Maintenance Message</label>
                <textarea
                  value={maintenanceMessage}
                  onChange={(e) => setMaintenanceMessage(e.target.value)}
                  rows={3}
                  className="flex w-full rounded-lg border border-border bg-surface-hover px-3 py-2 text-sm text-text placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                  placeholder="We're improving your experience..."
                />
              </div>
            )}

            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-text">Force App Update</p>
                <p className="text-xs text-text-muted">Require users to update the app</p>
              </div>
              <Switch
                checked={forceUpdate}
                onCheckedChange={setForceUpdate}
                className="data-[state=checked]:bg-warning data-[state=unchecked]:bg-border h-5 w-9 rounded-full relative"
              >
                <span className="data-[state=checked]:translate-x-4 data-[state=unchecked]:translate-x-0.5 block h-4 w-4 rounded-full bg-white transition-transform" />
              </Switch>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-secondary">Min App Version</label>
                <Input value={minVersion} onChange={(e) => setMinVersion(e.target.value)} placeholder="1.0.0" />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-secondary">Latest Version</label>
                <Input value={latestVersion} onChange={(e) => setLatestVersion(e.target.value)} placeholder="1.2.0" />
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Update URL</label>
              <Input value={updateUrl} onChange={(e) => setUpdateUrl(e.target.value)} placeholder="https://..." />
            </div>

            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-secondary">Max Upload (MB)</label>
                <Input type="number" value={maxUpload} onChange={(e) => setMaxUpload(e.target.value)} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-secondary">Default Credits</label>
                <Input type="number" value={defaultCredits} onChange={(e) => setDefaultCredits(e.target.value)} />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-text-secondary">Trial Days</label>
                <Input type="number" value={trialDays} onChange={(e) => setTrialDays(e.target.value)} />
              </div>
            </div>

            <Button onClick={handleSaveSettings} disabled={updateSettings.isPending} className="w-full">
              {updateSettings.isPending ? 'Saving...' : 'Save Settings'}
            </Button>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-surface p-6">
          <div className="flex items-center justify-between mb-5">
            <div className="flex items-center gap-2">
              <Flag className="h-5 w-5 text-primary" />
              <h2 className="text-lg font-semibold text-text">Feature Flags</h2>
            </div>
            <Button size="sm" onClick={() => setShowNewFlag(true)}>
              <Plus className="h-4 w-4 mr-1" /> Add
            </Button>
          </div>

          <div className="space-y-3">
            {flags?.map((flag) => (
              <div
                key={flag.id}
                className="flex items-center justify-between rounded-lg border border-border bg-surface-hover p-4"
              >
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-medium text-text">{flag.name}</p>
                    <code className="text-xs text-text-muted bg-background px-1.5 py-0.5 rounded font-mono">
                      {flag.key}
                    </code>
                  </div>
                  <p className="text-xs text-text-muted mt-0.5 truncate">{flag.description}</p>
                  {flag.percentage < 100 && (
                    <div className="flex items-center gap-2 mt-1.5">
                      <div className="h-1.5 w-20 rounded-full bg-background overflow-hidden">
                        <div
                          className="h-full rounded-full bg-primary"
                          style={{ width: `${flag.percentage}%` }}
                        />
                      </div>
                      <span className="text-xs text-text-muted">{flag.percentage}%</span>
                    </div>
                  )}
                </div>
                <Switch
                  checked={flag.enabled}
                  onCheckedChange={() => toggleFlag.mutate(flag.id)}
                  className="data-[state=checked]:bg-success data-[state=unchecked]:bg-border h-5 w-9 rounded-full relative shrink-0 ml-3"
                >
                  <span className="data-[state=checked]:translate-x-4 data-[state=unchecked]:translate-x-0.5 block h-4 w-4 rounded-full bg-white transition-transform" />
                </Switch>
              </div>
            ))}
            {(!flags || flags.length === 0) && (
              <p className="text-sm text-text-muted text-center py-8">No feature flags configured</p>
            )}
          </div>
        </div>
      </div>

      <Dialog open={showNewFlag} onOpenChange={setShowNewFlag}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>New Feature Flag</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Flag Key</label>
              <Input value={newFlagKey} onChange={(e) => setNewFlagKey(e.target.value)} placeholder="new_feature" />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Display Name</label>
              <Input value={newFlagName} onChange={(e) => setNewFlagName(e.target.value)} placeholder="New Feature" />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-text-secondary">Description</label>
              <Input value={newFlagDesc} onChange={(e) => setNewFlagDesc(e.target.value)} placeholder="Description..." />
            </div>
            <Button className="w-full" onClick={handleCreateFlag} disabled={!newFlagKey || !newFlagName}>
              Create Flag
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
