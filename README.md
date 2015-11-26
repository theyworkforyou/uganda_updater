# kuvukazim_updater

A webhook handler for updating the [`DATASOURCE`](https://github.com/mysociety/kuvakazim/blob/master/DATASOURCE) file in the KuvakaZim Jekyll site.

## Install

First you'll need make sure you've got a couple of system packages installed:

- ruby >= 2.0.0 (`brew install ruby` on a mac)
- redis (`brew install redis` on a mac)

Then you'll need to install some required gems:

    gem install bundler foreman

If installing gems fails with a permissions error you may need to prefix the command with `sudo`.

Next clone the repository from GitHub and change into the cloned directory.

    git clone https://github.com/everypolitician/kuvukazim_updater.git
    cd kuvukazim_updater

Now you need to install the project dependencies with bundler

    bundle install

Finally you'll need to [create a Personal Access Token on GitHub](http://github.com/settings/tokens). The default scopes are fine. Then copy `.env.example` to `.env` and add the generated access token.

    cp .env.example .env
    $EDITOR .env
    # Replace 'replace_with_github_access_token' with an actual access token

## Usage

To start the application's web and worker processes you can use foreman:

    foreman start

Then to trigger a rebuild you can manually make a `POST` request to `/`.

    curl -i -X POST http://localhost:5000/
