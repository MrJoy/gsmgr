# GSuite Manager

This project is a janky little web application for doing ACLs on a non-Workspace GSuite account.  It is absolutely a bad idea to actually use this for anything real.  Instead of using this, get Workspace, and use it as intended.

## Setup

First setup Homebrew, and make sure everything is up to date.

Clone this repo and `cd` into it.  Run the following to set up tools:

```bash
brew bundle --no-upgrade
git config core.autocrlf false
rbenv install
gem update --system
```

Add the following to `~/.profile` / `~/.zshrc` / whatever startup script your shell uses:

```bash
# Adjust as-needed, but make sure /usr/local/{bin,sbin} appear _before_ system bin paths!
export PATH="~/.rbenv/shims:/usr/local/bin:/usr/local/sbin:$PATH"
```

You will need NodeJS.  It's recommended that you use `nvm` (`brew install nvm`, then update RC
files as appropriate), but any sufficiently recent version of Node should be adequate.

Then run the following commands to finish setup:

```bash
cp template.env .env.development.local
# Now, edit .env.development.local with proper values.

gem install bundler:$(grep -A 1 'BUNDLED WITH' Gemfile.lock | tail -1 | awk '{ print $1 }')
bundle
rbenv rehash # Needed when adding gems that have binaries...
yarn install --link-duplicates --ignore-optional --check-files # Link-dupes and ignore-optional are optional but recommended.

rake db:create:all db:migrate db:seed
```

You'll need to put relevant credentials in the right places.  Notably, you should have a file named `.credentials.json` in the project root, and a file named `.env.development.local` whose contents are those of `template.env`, with the appropriate values filled in.

## Running Things

### Basic Flow

Postgres and Redis need to be running already, which they should be if you followed the recommended
setup flow.

```bash
bin/dev # Start everything.

rspec # Run tests
open coverage/index.html # See coverage report after running tests

rubocop --auto-correct # Run RuboCop, fix things that can (safely) be automatically fixed.

rake lint # Run all linters
```

* [Mailhog (Email delivered in dev)](http://localhost:8025/)

### Authorizing the App

* Visit the [authorize page](http://localhost:3000/auth/google/authorize), then when prompted select the relevant GSuite account and grant all permissions
  * You will see very scary warnings, because the app is not verified by Google.  This is fine, because you're running it locally and it's not accessible to the internet at large.

## Handy Links

### Google

* [GCP Console](https://console.cloud.google.com)
* [OAuth Mechanics](https://developers.google.com/identity/protocols/oauth2/)
* [People API](https://developers.google.com/people/)
* [Calendar API](https://developers.google.com/calendar/)
* [Drive API](https://developers.google.com/drive/)

### Testing

* [RSpec Rails](https://github.com/rspec/rspec-rails)
* [RSpec Rails Examples](https://github.com/eliotsykes/rspec-rails-examples)
* [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)
