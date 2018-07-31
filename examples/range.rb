require 'bundler'
Bundler.setup :default

require 'pp'
require 'logger'
require 'mpd_client'

MPD::Client.log = Logger.new($stderr)

client = MPD::Client.new
client.connect('localhost', 6600)

# delete all songs from the current playlist, except for the firts ten
client.delete([10,])

# move the first three songs after the fifth number in the playlist
client.move([0, 3], 5)

# print songs form 5 to 10
client.playlistinfo([5, 10]).each{ |s| puts "#{s['artist']} - #{s['title']}"}
