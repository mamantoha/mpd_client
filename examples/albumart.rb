# frozen_string_literal: true

require 'bundler'
Bundler.setup :default

require 'logger'
require 'mpd_client'

# MPD::Client.log = Logger.new($stderr)

client = MPD::Client.new
client.connect('localhost', 6600)

if (current_song = client.currentsong)
  data, io = client.albumart(current_song['file'])
  puts data
  File.write('cover.jpg', io.string)
end
