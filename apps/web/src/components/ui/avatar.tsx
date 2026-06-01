import { cn } from '@/lib/utils'

interface AvatarProps {
  src?: string
  alt: string
  fallback: string
  className?: string
}

export function Avatar({ src, alt, fallback, className }: AvatarProps) {
  if (src) {
    return (
      <img
        src={src}
        alt={alt}
        className={cn('w-8 h-8 rounded-full object-cover', className)}
      />
    )
  }

  return (
    <div
      className={cn(
        'w-8 h-8 rounded-full bg-primary/20 text-primary flex items-center justify-center text-sm font-medium',
        className
      )}
    >
      {fallback}
    </div>
  )
}
