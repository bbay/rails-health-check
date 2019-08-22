# Rails Health Check

## Fork notes

Added a  `/health` path that checks if DB exists and app responds
Fixed compatibility with newer Rails versions.

## Description

The gem is a simple solution if you want health check apis of latency and database.

## Installation

1. Put this into your Gemfile

``` ruby
gem 'rails-health-check'
```

and run ``bundle install``.

2. Start your rails application.

3. visit `/health/latency` and `/health/db`
