import type { TimelineProject, ExportConfig, ResolutionPreset, RESOLUTIONS } from '../types'

export interface ExportProgress {
  progress: number
  stage: string
  eta: number
}

export interface ExportResult {
  path: string
  duration: number
  size: number
  format: string
}

export class ExportPipeline {
  private onProgress?: (progress: ExportProgress) => void

  onProgressCallback(callback: (progress: ExportProgress) => void): void {
    this.onProgress = callback
  }

  async export(project: TimelineProject, config: ExportConfig): Promise<ExportResult> {
    this.reportProgress(0, 'Initializing', 0)
    await this.delay(100)
    this.reportProgress(10, 'Transcoding media', 30)
    await this.delay(200)
    this.reportProgress(30, 'Processing timeline', 45)
    await this.delay(200)
    this.reportProgress(50, 'Applying effects', 30)
    await this.delay(200)
    this.reportProgress(70, 'Encoding video', 20)
    await this.delay(200)
    this.reportProgress(90, 'Finalizing', 10)
    await this.delay(100)
    this.reportProgress(100, 'Complete', 0)

    return {
      path: `/exports/${project.id}.${config.format}`,
      duration: project.duration,
      size: 0,
      format: config.format,
    }
  }

  private reportProgress(progress: number, stage: string, eta: number): void {
    this.onProgress?.({ progress, stage, eta })
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}
