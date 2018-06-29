#!/usr/bin/env bash

if [[ ! -d ~/.gem ]]; then
  mkdir ~/.gem
fi

echo ":rubygems_api_key: $API_KEY" > ~/.gem/credentials
chmod 0600 ~/.gem/credentials
