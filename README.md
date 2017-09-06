# Dockup

Dockup creates disposable staging environments for your services using docker-compose.

You can automate staging deployments when you submit pull requests:
![github-webhook](https://s3-ap-southeast-1.amazonaws.com/uploads-ap.hipchat.com/39906/538857/k7WU2wiVbLzQMu6/upload.png "Github Webhook")

Or whenever you feel like, using Slack etc:
![chatops](https://s3-ap-southeast-1.amazonaws.com/uploads-ap.hipchat.com/39906/538857/YFBfOlZATG5ESNx/upload_censored.jpg "Chatops")

# Features:

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

Clone the repo and run:

    mix deps.get
    iex -S mix phoenix.server

You can access Dockup UI at http://localhost:4000.

### Development on OSX

    # Install latest elixir
    brew install elixir

    cd dockup
    ./scripts/setup


Once compilation runs fine, you can start dockup.
If you are running this on OSX, unless you have docker CLI available in the
development environment, you need to enable dry run mode in order to start
Dockup. Run:

    # Use this instead of iex -S mix phoenix.server
    DOCKUP_DRY_RUN=true iex -S mix phoenix.server


### Using Vagrant

It is recommended to use Vagrant for the following reasons:

1. You can use real docker and do real deployments on OSX
2. You can destroy containers and restart from a clean slate

A `Vagrantfile` is checked in which will provision an ubuntu machine with
everything ready for testing the app. Here's how you can set it up:

```
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ ./scripts/setup
```

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

## API

### /api/deployments

This API endpoint is used to deploy a dockerized app.

```
curl -XPOST  -d '{"git_url":"https://github.com/code-mancers/project.git","branch":"master","callback_url":"fake_callback"}' -H "Content-Type: application/json" http://localhost:4000/api/deployments
```
