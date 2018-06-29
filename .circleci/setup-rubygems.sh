#!/usr/bin/env bash

mkdir ~/.gem
echo ":rubygems_api_key: $API_KEY" > ~/.gem/credentials
chmod 0600 ~/.gem/credentials
