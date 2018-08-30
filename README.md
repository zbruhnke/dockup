# Dockup

Dockup creates disposable staging environments for your services using docker-compose.

You can automate staging deployments when you submit pull requests:
![github-webhook](https://user-images.githubusercontent.com/1707078/30229184-8715715c-94fe-11e7-8416-527e30128044.png)

Or whenever you feel like, using Slack etc:
![chatops](https://user-images.githubusercontent.com/1707078/30229222-a5d8ed30-94fe-11e7-83de-fa5dda3af8d5.png)

## Features:

- [x] Automatic staging environments for PRs using Github webhooks
- [x] API and UI to deploy apps in git reposisotries
- [x] Supports multi-container environments
- [x] Automatic creation/renewal of SSL certs using Letsencrypt
- [x] Basic auth
- [x] Automatic cleanup of expired environments
- [x] Tail logs of running apps

## Installation

1. Clone the repository
2. Inside the project directory, copy `.env.example` to `.env` and replace dummy values with actual ones
3. Run `docker-compose up`

## Supported Backends
Dockup now supports multiple backends for deploying apps. They include:

- `compose` : Uses `docker-compose.yaml` file in project root directory
- `helm` : Uses helm package under `helm` folder in project root directory
- `fake` : Stubs out deployments, useful for UI development.

Backend can be specified using `DOCKUP_BACKEND` environment variable. If no value
is specified, backend will be defaulted to `fake`


## Development

    # Install latest elixir
    brew install elixir

    cd dockup
    ./scripts/setup
    mix deps.get
    iex -S mix phx.server
    # to start your app with the google_oauth variable use(recommended)
    GOOGLE_CLIENT_ID=<GOOGLE_CLIENT_ID> GOOGLE_CLIENT_SECRET=<GOOGLE_CLIENT_SECRET> GOOGLE_CLIENT_DOMAINS=codemancers.com mix phx.server

You can access Dockup UI at http://localhost:4000.

## Production
Its advised to set dockup base domain using environment variable. Say if the
environment variable `DOCKUP_BASE_DOMAIN` is set to `dockup.yourdomain.com`,
then interface for dockup will be accessible at `ui.dockup.yourdomain.com`
This allows users to obtain wildcard certificate for base domain, and then
dockup will use the same wildcard.

## Configuration and Environment variables

All required environment variables are present in `.env.example`. Modify them
as needed when copying the file to `.env`. For additional configuration options,
refer `apps/dockup/lib/dockup/config.ex`.

### Basic Authentication

Set `DOCKUP_HTPASSWD` environment variable with the contents of the htpasswd file
generated using the desired username and password for basic auth. You can use
[this tool](http://www.htaccesstools.com/htpasswd-generator/) to generate this
string. The same username/password combo works for both dockup app and the log
tailing page.


### Whitelisting Git URLs

Dockup will not be able to deploy git repositories unless the git repo URLs
are whitelisted. To do this, use the "Whitelisted URLs" navbar link to create
whitelisted git URLs.


### Configuring github bot

To enable Github webhooks, you need to generate personal access token (OAuth token)
of a user(preferably a bot user) who has access to the repos you are planning to deploy using dockup.
Once you have it, set it in the environment variable `DOCKUP_GITHUB_OAUTH_TOKEN`
before starting dockup. This token will need "repo" scope which is configurable from
[the settings page](https://github.com/settings/tokens).

## API

### /api/deployments

This API endpoint is used to deploy a dockerized app.

```
curl -XPOST  -d '{"git_url":"https://github.com/code-mancers/project.git","branch":"master","callback_url":"fake_callback"}' -H "Content-Type: application/json" http://localhost:4000/api/deployments
```

### UI design by Sleekr

Dockup is thankful to Sleekr (https://sleekr.co) for providing their design and
development efforts to give dockup a professional look. They also helped in
piloting this project, and improving the tool.
