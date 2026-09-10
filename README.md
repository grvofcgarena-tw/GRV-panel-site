# GRV JavaScript Audio Tools

`grv-panel.js.org` is the public technical documentation site for GRV's JavaScript-based Discord audio tooling. It explains the integration of Node.js, yt-dlp, FFmpeg, `@discordjs/voice`, PCM mixing, speech tooling, and DAVE/E2EE voice transport.

This repository is intentionally a static GitHub Pages site. It contains no login form, database, bot token, cookies, production configuration, credentials, private certificates, or private management-panel code. The private GRV-panel application remains in its separate repository and deployment environment.

## Scope

The public site documents a JavaScript audio pipeline and links to the source project for technical reference. It does not automatically redirect visitors away from `js.org`, and all external links require an explicit user action.

## GitHub Pages

The `main` branch is deployed by `.github/workflows/pages.yml`. The `CNAME` file contains `grv-panel.js.org`. After GitHub Pages is enabled for this repository, configure `grv-panel.js.org` as the Pages custom domain if GitHub asks for it.

## Local preview

No build step is required:

```bash
python3 -m http.server 8080
```

Then open `http://127.0.0.1:8080`.

## Relationship to the private application

The public site is documentation only. It must never receive or copy `.env`, GitHub tokens, Gmail App Passwords, Discord tokens, SQLite databases, session files, cookies, Cloudflare credentials, TLS private keys, or production logs from the private GRV-panel repository.

## License and source

The implementation and deployment configuration are maintained by the GRV project. Third-party services and media sources remain subject to their own terms of use.
