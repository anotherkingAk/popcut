import type { Keyframe, EasingType } from '../types'

export class KeyframeEngine {
  evaluate(keyframes: Keyframe[], time: number): number {
    if (keyframes.length === 0) return 0
    if (keyframes.length === 1) return keyframes[0].value

    const sorted = [...keyframes].sort((a, b) => a.time - b.time)

    if (time <= sorted[0].time) return sorted[0].value
    if (time >= sorted[sorted.length - 1].time) return sorted[sorted.length - 1].value

    for (let i = 0; i < sorted.length - 1; i++) {
      const a = sorted[i]
      const b = sorted[i + 1]
      if (time >= a.time && time <= b.time) {
        const t = (time - a.time) / (b.time - a.time)
        const eased = this.applyEasing(t, a.easing)
        return a.value + (b.value - a.value) * eased
      }
    }

    return sorted[sorted.length - 1].value
  }

  private applyEasing(t: number, easing: EasingType): number {
    switch (easing) {
      case 'linear': return t
      case 'easeIn': return t * t
      case 'easeOut': return t * (2 - t)
      case 'easeInOut': return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
      case 'bounce': {
        const n1 = 7.5625
        const d1 = 2.75
        if (t < 1 / d1) return n1 * t * t
        if (t < 2 / d1) return n1 * (t -= 1.5 / d1) * t + 0.75
        if (t < 2.5 / d1) return n1 * (t -= 2.25 / d1) * t + 0.9375
        return n1 * (t -= 2.625 / d1) * t + 0.984375
      }
      case 'elastic': {
        const c4 = (2 * Math.PI) / 3
        if (t === 0) return 0
        if (t === 1) return 1
        return Math.pow(2, -10 * t) * Math.sin((t * 10 - 0.75) * c4) + 1
      }
      default: return t
    }
  }
}
