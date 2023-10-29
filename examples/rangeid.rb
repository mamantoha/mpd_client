# frozen_string_literal: true

require 'bundler'
Bundler.setup :default

require 'logger'
require 'mpd_client'

MPD::Client.log = Logger.new($stderr)

client = MPD::Client.new
client.connect('localhost', 6600)

# Get id of the first song in the playllist
song = client.playlistinfo(1).first
pp "#{song['artist']} - #{song['title']}"
song_id = song['id']

# Specifies the portion of the song that shall be played
client.rangeid(song_id, [60, 70])

# Play the playlist at song 1
client.play(1)

pp client.status
