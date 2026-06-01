export interface MediaFile {
  id: string
  name: string
  path: string
  type: 'video' | 'audio' | 'image'
  duration: number
  width: number
  height: number
  size: number
  thumbnailPath?: string
}

export class MediaManager {
  private files: Map<string, MediaFile> = new Map()

  addFile(file: MediaFile): void {
    this.files.set(file.id, file)
  }

  removeFile(id: string): void {
    this.files.delete(id)
  }

  getFile(id: string): MediaFile | undefined {
    return this.files.get(id)
  }

  getAllFiles(): MediaFile[] {
    return Array.from(this.files.values())
  }

  getByType(type: MediaFile['type']): MediaFile[] {
    return this.getAllFiles().filter(f => f.type === type)
  }

  clear(): void {
    this.files.clear()
  }
}
