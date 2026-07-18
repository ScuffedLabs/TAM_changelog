export const isEnvBrowser = (): boolean => !(window as Window & { invokeNative?: unknown }).invokeNative

export const noop = () => {}
