# frozen_string_literal: true

require 'bundler'
Bundler.setup :default

require 'logger'
require 'mpd_client'

client = MPD::Client.new

client = MPD::Client.new
client.log = Logger.new($stderr)

client.connect('localhost', 6600)

# Lists all changed systems:
# database, update, stored_playlist, playlist, player, mixer, output, options, sticker, subscription, message
#
subsystems = %w[player playlist]

loop do
  resp = client.idle(*subsystems)
  puts resp
end

client.close
client.disconnect
