# encoding: utf-8

require 'bundler'
Bundler.setup :default

require 'logger'
require 'mpd_client'

MPDClient.log = Logger.new($stderr)

# Stickers
# http://www.musicpd.org/doc/protocol/ch03s07.html

client = MPDClient.new

# Connecting to the server
client.connect('/run/mpd/socket')

puts "MPD version: #{client.mpd_version}"
puts "mpd_client version: #{MPDClient::VERSION}"

uri = "world/j/Jane Air/2012.Иллюзия полёта/12. Любить любовь.ogg"

# sticker set {TYPE} {URI} {NAME} {VALUE}
#   Adds a sticker value to the specified object. If a sticker item with that name already exists, it is replaced.
#
client.sticker_set('song', uri, 'rating', '1')

# sticker get {TYPE} {URI} {NAME}
#   Reads a sticker value for the specified object.
#
puts client.sticker_get('song', uri, 'rating')

# sticker list {TYPE} {URI}
#   Lists the stickers for the specified object.
#
puts client.sticker_list('song', uri)

# sticker find {TYPE} {URI} {NAME}
#   Searches the sticker database for stickers with the specified name, below the specified directory (URI).
#   For each matching song, it prints the URI and that one sticker's value.
#
puts client.sticker_find('song', '/', 'rating')

# sticker delete {TYPE} {URI} [NAME]
#   Deletes a sticker value from the specified object. If you do not specify a sticker name, all sticker values are deleted.
#
client.sticker_delete('song', uri, 'rating')

client.close
client.disconnect
