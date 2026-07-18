import { useEffect, useRef } from "react"

import { noop } from "./misc"

interface NuiMessageData<T = unknown> {
  action: string
  data: T
}

type NuiHandler<T> = (data: T) => void

export function useNuiEvent<T = unknown>(action: string, handler: NuiHandler<T>): void {
  const savedHandler = useRef<NuiHandler<T>>(noop)

  useEffect(() => {
    savedHandler.current = handler
  }, [handler])

  useEffect(() => {
    const listener = (event: MessageEvent<NuiMessageData<T>>) => {
      if (!event.data || event.data.action !== action) return
      savedHandler.current(event.data.data)
    }

    window.addEventListener("message", listener)
    return () => window.removeEventListener("message", listener)
  }, [action])
}
