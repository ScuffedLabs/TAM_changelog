# Advanced Changelog

SCFD Changelog is a modern, framework-agnostic changelog system for FiveM, featuring a clean and secure UI designed to keep players informed about every server update.

Display rich release notes with version history, categories, metadata, optional Discord publishing, and automatic update notifications - all from a single `CHANGELOG.md` file.

## Key Features

* 📖 Modern React + shadcn changelog interface
* 🗂️ Browse previous releases through built-in version history
* 🏷️ Filter updates by configurable categories
* ✨ Rich release metadata including titles, summaries, authors, dates, and importance flags
* 🔔 Automatically display new changelogs once per resource version
* 📤 Optional Discord webhook publishing
* ⚡ Server-side parsing with automatic caching
* 🔒 Secure, validated rendering with no HTML or JavaScript execution
* 🎨 Multiple built-in themes including Scuffed Labs and several shadcn color variants
* 🧩 Client and server exports for complete integration with your own resources

## Integration & Customization

* Works standalone with no framework dependency.
* Uses **ox_lib** only for shared initialization and localization.
* Fully configurable through simple configuration files.
* Release information is generated entirely from `CHANGELOG.md`.
* Supports custom release metadata, categories, and version history.
* Built-in exports allow other resources to display or query changelog information.
* Easily integrate with existing menus, dashboards, or welcome screens.

## Security

Security was a primary goal during development.

* Changelog files are parsed exclusively on the server.
* Clients never submit changelog content.
* All data is validated before being sent to the UI.
* The interface renders plain text only—no HTML rendering or runtime script execution.
* Includes a restrictive Content Security Policy and additional validation to prevent injection attacks.

## Documentation

The resource supports:

* Rich release metadata
* Category-based entries
* Automatic version tracking
* Client and server exports
* Discord webhook publishing
* Configurable themes
* Full localization

Complete documentation, examples, and API references are available on the Scuffed Labs documentation website.

## Documentation & Support

* **Documentation:** https://docs.scuffedlabs.com
* **Support Discord:** https://scuffedlabs.com/discord
* **Website:** https://scuffedlabs.com

## Requirements

* FiveM server artifacts
* ox_lib **3.30.0** or newer

## Installation

```cfg
ensure ox_lib
ensure scfd_changelog
```

The resource folder must remain named `scfd_changelog`.

## Credits

* Created and maintained by **Scuffed Labs**.

## License

This resource is released under the **Scuffed Labs Community License (SLCL)**.

See `LICENSE.md` for the complete license.
