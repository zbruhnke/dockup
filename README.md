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
2. Inside the project directory, copy `.env.example` to `.env` and modify environment variables as needed
3. Run `docker-compose up`

## Development

    # Install latest elixir
    brew install elixir

    cd dockup
    ./scripts/setup
    mix deps.get
    iex -S mix phx.server

You can access Dockup UI at http://localhost:4000.

## Configuration and Environment variables

Refer `apps/dockup/lib/dockup/config.ex` to see the list of environment variables
supported.

### Basic Authentication

Set `DOCKUP_HTPASSWD` environment variable with the contents of the htpasswd file
generated using the desired username and password for basic auth. You can use
[this tool](http://www.htaccesstools.com/htpasswd-generator/) to generate this
string.


### Whitelisting Git URLs

Dockup will not be able to deploy git repositories unless the git repo URLs
are whitelisted. To do this, create a file named "whitelisted_urls" inside
the "workdir" directory. Insert the git repo urls in this file, one URL on each
line. For example:

```
https://github.com/code-mancers/repo1.git
https://github.com/code-mancers/repo2.git
```

### Github webhooks

To enable Github webhooks, you need to generate personal access token (OAuth token)
of a user who has access to the repos you are planning to deploy using dockup.
Once you have it, set it in the environment variable `DOCKUP_GITHUB_OAUTH_TOKEN`
before starting dockup.

## API

### /api/deployments

This API endpoint is used to deploy a dockerized app.

```
curl -XPOST  -d '{"git_url":"https://github.com/code-mancers/project.git","branch":"master","callback_url":"fake_callback"}' -H "Content-Type: application/json" http://localhost:4000/api/deployments
```
