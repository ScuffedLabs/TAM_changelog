export const CHANGELOG_THEMES = [
  "scuffed",
  "neutral",
  "blue",
  "green",
  "orange",
  "rose",
  "violet",
] as const

export type ChangelogTheme = (typeof CHANGELOG_THEMES)[number]

export interface Entry {
  category: string
  text: string
}

export interface Section {
  title: string
  entries: Entry[]
}

export interface Release {
  version: string
  date: string
  title: string
  summary: string
  author: string
  important: boolean
  categories: string[]
  sections: Section[]
}

export interface ChangelogData {
  title: string
  subtitle: string
  defaultCategory: string
  theme: ChangelogTheme
  releases: Release[]
  categories: string[]
}

export interface OpenPayload {
  data: ChangelogData
  selectedVersion?: string | null
}
