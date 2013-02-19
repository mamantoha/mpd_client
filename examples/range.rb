require 'bundler'
Bundler.setup :default

require 'pp'
require 'logger'
require 'mpd_client'

MPDClient.log = Logger.new($stderr)

client = MPDClient.new
client.connect('localhost', 6600)

# delete all songs from the current playlist, except for the firts ten
client.delete([10,])

# move the first three songs after the fifth number in the playlist
client.move([0, 3], 69)

pp client.playlistinfo([69, 71])
