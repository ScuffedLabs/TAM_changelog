import { isEnvBrowser } from "./misc";

export async function fetchNui<T = unknown>(
	eventName: string,
	data?: unknown,
	mockData?: T,
): Promise<T> {
	if (isEnvBrowser() && mockData !== undefined) return mockData;

	const resourceName =
		(
			window as Window & { GetParentResourceName?: () => string }
		).GetParentResourceName?.() ?? "nui-frame-app";

	const response = await fetch(`https://${resourceName}/${eventName}`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json; charset=UTF-8",
		},
		body: JSON.stringify(data ?? {}),
	});

	if (!response.ok) {
		throw new Error(
			`NUI callback '${eventName}' failed with status ${response.status}`,
		);
	}

	return response.json() as Promise<T>;
}
