# frozen_string_literal: true

require 'bundler'
Bundler.setup :default

require 'logger'
require 'mpd_client'

# MPD::Client.log = Logger.new($stderr)

client = MPD::Client.new

type = ARGV[0]
what = ARGV[1]

client = MPD::Client.new
client.log = Logger.new($stderr)

# Connecting to the server
client.connect('localhost', 6600)

puts "MPD version: #{client.mpd_version}"
puts "mpd_client version: #{MPD::Client::VERSION}"

client.stop
client.clear # clear the current playlist

# Finds songs in the db that are exactly `what`.
# `type` can be any tag supported by MPD
# or one of the two special parameters:
# * 'file' - to search by full path (relative to database root),
# * 'any' - to match against all available tags.
songs = client.search(type, what)

client.command_list_ok_begin # start a command list to speed up operations
songs.each do |song|
  client.add(song['file']) if song.key?('file')
end
client.command_list_end

client.play

client.close
client.disconnect # disconnect from the server
