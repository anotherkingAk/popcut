'use client'

import { QueryClient } from '@tanstack/react-query'

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 120_000,
        gcTime: 300_000,
        retry: 1,
        refetchOnWindowFocus: false,
        refetchOnMount: false,
      },
    },
  })
}

let browserQueryClient: QueryClient | undefined

export function getQueryClient() {
  if (typeof window === 'undefined') return makeQueryClient()
  if (!browserQueryClient) browserQueryClient = makeQueryClient()
  return browserQueryClient
}
