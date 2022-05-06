# frozen_string_literal: true

require 'bundler'
Bundler.setup :default

require 'logger'
require 'mpd_client'

MPD::Client.log = Logger.new($stderr)

client = MPD::Client.new
client.connect('localhost', 6600)

puts client.currentsong
