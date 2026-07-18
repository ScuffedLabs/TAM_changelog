import { CHANGELOG_THEMES, type ChangelogData, type Entry, type Release, type Section } from "@/types"

const isString = (value: unknown, maxLength: number): value is string =>
  typeof value === "string" && value.length <= maxLength

const isEntry = (value: unknown): value is Entry => {
  if (!value || typeof value !== "object") return false
  const entry = value as Partial<Entry>
  return isString(entry.category, 40) && isString(entry.text, 500)
}

const isSection = (value: unknown): value is Section => {
  if (!value || typeof value !== "object") return false
  const section = value as Partial<Section>
  return (
    isString(section.title, 40) &&
    Array.isArray(section.entries) &&
    section.entries.length <= 250 &&
    section.entries.every(isEntry)
  )
}

const isRelease = (value: unknown): value is Release => {
  if (!value || typeof value !== "object") return false
  const release = value as Partial<Release>

  return (
    isString(release.version, 40) &&
    isString(release.date, 64) &&
    isString(release.title, 120) &&
    isString(release.summary, 1000) &&
    isString(release.author, 80) &&
    typeof release.important === "boolean" &&
    Array.isArray(release.categories) &&
    release.categories.length <= 100 &&
    release.categories.every((category) => isString(category, 40)) &&
    Array.isArray(release.sections) &&
    release.sections.length <= 20 &&
    release.sections.every(isSection)
  )
}

export const isChangelogData = (value: unknown): value is ChangelogData => {
  if (!value || typeof value !== "object") return false
  const data = value as Partial<ChangelogData>

  return (
    isString(data.title, 100) &&
    isString(data.subtitle, 180) &&
    isString(data.defaultCategory, 40) &&
    CHANGELOG_THEMES.includes(data.theme as ChangelogData["theme"]) &&
    Array.isArray(data.categories) &&
    data.categories.length <= 101 &&
    data.categories.every((category) => isString(category, 40)) &&
    Array.isArray(data.releases) &&
    data.releases.length <= 100 &&
    data.releases.every(isRelease)
  )
}
