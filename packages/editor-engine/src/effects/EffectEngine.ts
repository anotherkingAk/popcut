import type { Effect, Clip } from '../types'

export interface EffectProcessor {
  type: string
  process: (frame: ImageData, params: Record<string, number | string | boolean>) => ImageData
}

export class EffectEngine {
  private processors: Map<string, EffectProcessor> = new Map()

  registerProcessor(processor: EffectProcessor): void {
    this.processors.set(processor.type, processor)
  }

  getProcessor(type: string): EffectProcessor | undefined {
    return this.processors.get(type)
  }

  applyEffects(frame: ImageData, clip: Clip): ImageData {
    let result = frame
    for (const effect of clip.effects) {
      if (!effect.enabled) continue
      const processor = this.processors.get(effect.type)
      if (processor) {
        result = processor.process(result, effect.params)
      }
    }
    return result
  }

  getRegisteredTypes(): string[] {
    return Array.from(this.processors.keys())
  }
}
