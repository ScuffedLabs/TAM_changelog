import * as React from "react"
import {
    IconAlertTriangle,
    IconCalendarEvent,
    IconCheck,
    IconChevronRight,
    IconCode,
    IconHistory,
    IconShieldCheck,
    IconSparkles,
    IconTag,
    IconUser,
    IconX,
} from "@tabler/icons-react"

import { Button } from "@/components/ui/button"
import { fetchNui } from "@/lib/fetchNui"
import { themeClasses } from "@/lib/themes"
import { useNuiEvent } from "@/lib/useNuiEvent"
import { cn } from "@/lib/utils"
import { isChangelogData } from "@/lib/validation"
import type { ChangelogData, OpenPayload, Release } from "@/types"

const sectionIcons: Record<string, React.ComponentType<{ className?: string }>> = {
    Added: IconSparkles,
    Changed: IconCode,
    Fixed: IconCheck,
    Security: IconShieldCheck,
    Removed: IconAlertTriangle,
    Deprecated: IconAlertTriangle,
}

type Visibility = "open" | "closing"

function getInitialVersion(data: ChangelogData, requested?: string | null): string {
    if (requested && data.releases.some((release) => release.version === requested)) return requested
    return data.releases[0]?.version ?? ""
}

function getReleaseCategories(release: Release): string[] {
    return ["All", ...release.categories.filter((category) => category !== "All")]
}

export function App() {
    const [data, setData] = React.useState<ChangelogData | null>(null)
    const [version, setVersion] = React.useState("")
    const [category, setCategory] = React.useState("All")
    const [visibility, setVisibility] = React.useState<Visibility>("open")

    const close = React.useCallback(() => {
        if (data && visibility === "open") setVisibility("closing")
    }, [data, visibility])

    useNuiEvent<OpenPayload>("changelog:open", React.useCallback((payload) => {
        if (!payload || !isChangelogData(payload.data)) return

        setData(payload.data)
        setVersion(getInitialVersion(payload.data, payload.selectedVersion))
        setCategory(
            payload.data.categories.includes(payload.data.defaultCategory)
                ? payload.data.defaultCategory
                : "All",
        )
        setVisibility("open")
    }, []))

    React.useEffect(() => {
        const onKeyDown = (event: KeyboardEvent) => {
            if (event.key === "Escape") close()
        }

        window.addEventListener("keydown", onKeyDown)
        return () => window.removeEventListener("keydown", onKeyDown)
    }, [close])

    const release = React.useMemo(
        () => data?.releases.find((item) => item.version === version) ?? data?.releases[0],
        [data, version],
    )

    const releaseCategories = React.useMemo(
        () => (release ? getReleaseCategories(release) : ["All"]),
        [release],
    )

    const filteredSections = React.useMemo(() => {
        if (!release || category === "All") return release?.sections ?? []

        return release.sections
            .map((section) => ({
                ...section,
                entries: section.entries.filter((entry) => entry.category === category),
            }))
            .filter((section) => section.entries.length > 0)
    }, [release, category])

    const handleAnimationEnd = React.useCallback(
        (event: React.AnimationEvent<HTMLElement>) => {
            if (event.target !== event.currentTarget || visibility !== "closing") return

            setData(null)
            setVersion("")
            setCategory("All")
            void fetchNui<{ ok: boolean }>("close", {}, { ok: true }).catch(() => undefined)
        },
        [visibility],
    )

    if (!data || !release) return null

    return (
        <main
            onAnimationEnd={handleAnimationEnd}
            className={cn(
                "flex min-h-screen items-center justify-center p-6",
                visibility === "open"
                    ? "animate-in fade-in zoom-in-95 duration-200"
                    : "animate-out fade-out zoom-out-95 duration-150",
                themeClasses[data.theme],
            )}
        >
            <section className="flex h-[min(800px,88vh)] w-[min(1180px,94vw)] min-w-0 overflow-hidden rounded-xl border bg-card text-card-foreground shadow-2xl">
                <aside className="flex w-68 shrink-0 flex-col border-r bg-background max-[900px]:w-56 max-[680px]:hidden">
                    <div className="border-b p-5">
                        <div className="flex items-center gap-1.5 text-[0.7rem] font-bold tracking-wider text-muted-foreground uppercase">
                            <IconHistory className="size-3.5" />
                            Version history
                        </div>
                        <h2 className="mt-3 text-base font-semibold">Changelog</h2>
                    </div>

                    <div className="min-h-0 flex-1 space-y-1.5 overflow-y-auto p-2.5">
                        {data.releases.map((item) => {
                            const active = item.version === release.version

                            return (
                                <button
                                    key={item.version}
                                    type="button"
                                    onClick={() => {
                                        setVersion(item.version)
                                        setCategory("All")
                                    }}
                                    className={cn(
                                        "flex w-full items-center gap-3 rounded-lg border border-transparent p-3 text-left text-muted-foreground transition-colors duration-150 hover:bg-secondary hover:text-foreground",
                                        active && "border-border bg-secondary text-foreground",
                                    )}
                                >
                                    <span className="flex min-w-0 flex-1 flex-col">
                                        <span className="font-mono text-xs font-bold">v{item.version}</span>
                                        <span className="mt-1 truncate text-xs">{item.title}</span>
                                        <span className="mt-1 text-[0.68rem] text-muted-foreground">{item.date}</span>
                                    </span>
                                    {item.important ? (
                                        <IconAlertTriangle className="size-4 shrink-0 text-destructive" />
                                    ) : (
                                        <IconChevronRight className="size-4 shrink-0" />
                                    )}
                                </button>
                            )
                        })}
                    </div>
                </aside>

                <div className="flex min-w-0 flex-1 flex-col">
                    <header className="flex items-start justify-between gap-5 border-b px-7 py-6 max-[680px]:px-4">
                        <div className="min-w-0">
                            <div className="text-[0.7rem] font-bold tracking-wider text-muted-foreground uppercase">
                                {data.title}
                            </div>
                            <h1 className="mt-2 text-4xl font-bold tracking-tight max-[680px]:text-3xl">
                                {release.title}
                            </h1>
                            {release.summary && (
                                <p className="mt-2.5 max-w-3xl text-sm leading-6 text-muted-foreground">
                                    {release.summary}
                                </p>
                            )}
                        </div>

                        <Button variant="outline" size="icon-lg" aria-label="Close changelog" onClick={close}>
                            <IconX />
                        </Button>
                    </header>

                    <div className="border-b px-7 py-3.5 max-[680px]:px-4">
                        <div className="flex flex-wrap gap-2">
                            <Metadata icon={IconHistory}>v{release.version}</Metadata>
                            <Metadata icon={IconCalendarEvent}>{release.date}</Metadata>
                            {release.author && <Metadata icon={IconUser}>{release.author}</Metadata>}
                            {release.important && (
                                <Metadata icon={IconAlertTriangle} important>
                                    Important
                                </Metadata>
                            )}
                        </div>

                        <div className="mt-3 flex gap-2 overflow-x-auto pb-0.5">
                            {releaseCategories.map((item) => (
                                <Button
                                    key={item}
                                    variant={category === item ? "default" : "outline"}
                                    onClick={() => setCategory(item)}
                                    className="shrink-0"
                                >
                                    <IconTag />
                                    {item}
                                </Button>
                            ))}
                        </div>
                    </div>

                    <div className="min-h-0 flex-1 overflow-y-auto px-7 py-5 max-[680px]:px-4">
                        {filteredSections.length ? (
                            <div className="grid grid-cols-2 gap-3.5 max-[900px]:grid-cols-1">
                                {filteredSections.map((section) => {
                                    const Icon = sectionIcons[section.title] ?? IconCode

                                    return (
                                        <article key={section.title} className="rounded-lg border bg-background p-4">
                                            <div className="flex items-center gap-2.5 border-b pb-3">
                                                <span className="flex size-8 items-center justify-center rounded-md bg-secondary text-primary">
                                                    <Icon className="size-4" />
                                                </span>
                                                <h3 className="text-xs font-bold tracking-wide uppercase">{section.title}</h3>
                                                <span className="ml-auto font-mono text-[0.68rem] text-muted-foreground">
                                                    {section.entries.length}
                                                </span>
                                            </div>

                                            <ul className="mt-3 grid gap-2.5">
                                                {section.entries.map((entry, index) => (
                                                    <li key={`${section.title}-${index}`} className="flex gap-2.5 text-xs leading-6">
                                                        <span className="mt-2.5 size-1.5 shrink-0 rounded-full bg-primary" />
                                                        <span>
                                                            <span className="mr-2 inline-flex rounded border bg-secondary px-1.5 py-0.5 font-mono text-[0.6rem] text-muted-foreground uppercase">
                                                                {entry.category}
                                                            </span>
                                                            {entry.text}
                                                        </span>
                                                    </li>
                                                ))}
                                            </ul>
                                        </article>
                                    )
                                })}
                            </div>
                        ) : (
                            <div className="flex min-h-64 flex-col items-center justify-center rounded-lg border border-dashed text-muted-foreground">
                                <IconTag className="size-7" />
                                <p className="mt-2.5 text-xs">No changes in this category</p>
                            </div>
                        )}
                    </div>

                    <footer className="flex justify-between border-t px-7 py-2.5 text-[0.67rem] text-muted-foreground max-[680px]:px-4">
                        <span>ESC to close</span>
                        <span>Scuffed Labs</span>
                    </footer>
                </div>
            </section>
        </main>
    )
}

interface MetadataProps {
    children: React.ReactNode
    icon: React.ComponentType<{ className?: string }>
    important?: boolean
}

function Metadata({ children, icon: Icon, important = false }: MetadataProps) {
    return (
        <span
            className={cn(
                "inline-flex items-center gap-1.5 rounded-md border bg-secondary px-2 py-1 text-[0.7rem] text-muted-foreground",
                important && "text-destructive",
            )}
        >
            <Icon className="size-3.5" />
            {children}
        </span>
    )
}

export default App
