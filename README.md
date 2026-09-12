# GRV JavaScript Audio Tools

`grvffws.js.org` is the public technical documentation site for GRV's JavaScript-based Discord audio tooling. It explains the integration of Node.js, yt-dlp, FFmpeg, `@discordjs/voice`, PCM mixing, speech tooling, and DAVE/E2EE voice transport.

This repository is intentionally a static GitHub Pages site. It contains no login form, database, bot token, cookies, production configuration, credentials, private certificates, or private management-panel code. The private GRV-panel application remains in its separate repository and deployment environment.

## Scope

The public site documents a JavaScript audio pipeline and links to the source project for technical reference. It does not automatically redirect visitors away from `js.org`, and all external links require an explicit user action.

## GitHub Pages

The `main` branch is deployed by `.github/workflows/pages.yml`. The `CNAME` file contains `grvffws.js.org`. After GitHub Pages is enabled for this repository, configure `grvffws.js.org` as the Pages custom domain if GitHub asks for it.

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

## Run locally and expose through Cloudflared

The site can remain on a phone instead of using GitHub Pages as its runtime host. In native Termux, make the scripts executable and start the local origin:

```bash
cd "$HOME/GRV-panel-site"
chmod +x scripts/serve-local.sh scripts/start-local-tunnel.sh
./scripts/serve-local.sh
```

In a second native Termux session, configure the existing Cloudflare Tunnel without committing any token or credentials:

```bash
cd "$HOME/GRV-panel-site"
export TUNNEL_DOMAIN='grvffws.js.org'
export CLOUDFLARED_TUNNEL_NAME='your-tunnel-name-or-uuid'
export CLOUDFLARED_TUNNEL_TOKEN="$(cat "$HOME/.cloudflared/grv-tunnel.token")"
./scripts/start-local-tunnel.sh
```

The tunnel origin is plain HTTP on `127.0.0.1:8090`; Cloudflare terminates public HTTPS. This static companion site does not need the private GRV-panel origin certificate or the private Node application.
