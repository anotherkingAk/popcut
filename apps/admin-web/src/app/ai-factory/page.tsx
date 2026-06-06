'use client'

import { useState } from 'react'
import { AdminLayout } from '@/components/AdminLayout'
import { Sparkles, Loader2, CheckCircle, XCircle } from 'lucide-react'

const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4001'

export default function AIFactoryPage() {
  const [prompt, setPrompt] = useState('')
  const [type, setType] = useState('effect')
  const [generating, setGenerating] = useState(false)
  const [result, setResult] = useState<any>(null)
  const [error, setError] = useState('')

  const handleGenerate = async (e: React.FormEvent) => {
    e.preventDefault()
    setGenerating(true)
    setError('')
    setResult(null)
    try {
      const token = localStorage.getItem('admin_token')
      const res = await fetch(`${API}/api/v1/admin/ai-factory/generate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ prompt, type }),
      })
      if (!res.ok) throw new Error('Generation failed')
      const data = await res.json()
      setResult(data)
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Generation failed')
    } finally {
      setGenerating(false)
    }
  }

  return (
    <AdminLayout>
      <div className="mb-6"><h1 className="text-2xl font-bold text-text">AI Factory</h1><p className="text-sm text-text-muted">Generate assets using AI prompts</p></div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="space-y-4">
          <div className="rounded-xl bg-surface border border-border p-4">
            <h2 className="text-sm font-semibold text-text mb-3">Generate Asset</h2>
            <form onSubmit={handleGenerate} className="space-y-3">
              <div>
                <label className="text-xs text-text-secondary mb-1 block">Asset Type</label>
                <select value={type} onChange={e => setType(e.target.value)}
                  className="w-full h-9 rounded-lg bg-background border border-border px-3 text-sm text-text outline-none focus:border-primary">
                  <option value="effect">Effect</option>
                  <option value="transition">Transition</option>
                  <option value="filter">Filter</option>
                  <option value="template">Template</option>
                  <option value="font-animation">Font Animation</option>
                </select>
              </div>
              <div>
                <label className="text-xs text-text-secondary mb-1 block">Prompt</label>
                <textarea
                  value={prompt}
                  onChange={e => setPrompt(e.target.value)}
                  placeholder="Describe what you want to generate...&#10;e.g. 'Cinematic wedding glow with warm highlights'"
                  className="w-full h-32 rounded-lg bg-background border border-border px-3 py-2 text-sm text-text placeholder:text-text-muted outline-none focus:border-primary resize-none"
                  required
                />
              </div>
              <button
                type="submit"
                disabled={generating || !prompt}
                className="flex items-center gap-2 px-4 py-2 rounded-lg bg-primary text-white text-sm hover:bg-primary-hover disabled:opacity-50 transition-colors"
              >
                {generating ? <Loader2 className="w-4 h-4 animate-spin" /> : <Sparkles className="w-4 h-4" />}
                {generating ? 'Generating...' : 'Generate'}
              </button>
            </form>
          </div>

          <div className="rounded-xl bg-surface border border-border p-4">
            <h2 className="text-sm font-semibold text-text mb-3">Pipeline Status</h2>
            <div className="space-y-3">
              {['Prompt → AI Service → Generate Asset → Generate Preview → Validation → Publish Queue'].map((step, i) => (
                <div key={i} className="flex items-center gap-2 text-xs text-text-secondary">
                  <div className="w-5 h-5 rounded-full bg-primary/20 text-primary flex items-center justify-center text-[10px] font-bold">{i + 1}</div>
                  {step}
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <div className="rounded-xl bg-surface border border-border p-4">
            <h2 className="text-sm font-semibold text-text mb-3">Output</h2>
            {error && (
              <div className="flex items-center gap-2 p-3 rounded-lg bg-danger/10 border border-danger/20 text-sm text-danger">
                <XCircle className="w-4 h-4 shrink-0" /> {error}
              </div>
            )}
            {result && (
              <div className="space-y-3">
                <div className="flex items-center gap-2 text-sm text-success">
                  <CheckCircle className="w-4 h-4" /> Asset generated successfully
                </div>
                <pre className="text-xs text-text-secondary bg-background p-3 rounded-lg overflow-auto max-h-60">
                  {JSON.stringify(result, null, 2)}
                </pre>
                <div className="flex gap-2">
                  <button className="px-3 py-1.5 rounded-lg bg-primary text-white text-xs hover:bg-primary-hover transition-colors">Publish to Library</button>
                  <button className="px-3 py-1.5 rounded-lg bg-surface-hover text-text-secondary text-xs hover:text-text transition-colors">Discard</button>
                </div>
              </div>
            )}
            {!result && !error && (
              <p className="text-sm text-text-muted text-center py-12">Generated assets will appear here</p>
            )}
          </div>

          <div className="rounded-xl bg-surface border border-border p-4">
            <h2 className="text-sm font-semibold text-text mb-3">Recent AI Jobs</h2>
            <p className="text-xs text-text-muted text-center py-6">Monitoring view - check AI Jobs page for full list</p>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
