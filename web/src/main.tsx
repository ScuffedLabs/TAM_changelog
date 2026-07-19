import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { isEnvBrowser } from "./lib/misc";

import App from "./App";
import "./index.css";

if (isEnvBrowser()) {
	const root = document.getElementById("root");

	// https://i.imgur.com/iPTAdYV.png - Night time img
	root!.style.backgroundImage = 'url("https://i.imgur.com/e64SL2N.png")';
	root!.style.backgroundSize = "cover";
	root!.style.backgroundRepeat = "no-repeat";
	root!.style.backgroundPosition = "center";
}

const root = document.getElementById("root");

createRoot(root!).render(
	<StrictMode>
		<App />
	</StrictMode>,
);
