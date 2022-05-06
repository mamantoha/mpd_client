# MPD::Client

[![Build Status](https://badgen.net/travis/mamantoha/mpd_client)](https://travis-ci.org/mamantoha/mpd_client)
[![Gem Version](https://badge.fury.io/rb/mpd_client.svg)](https://badge.fury.io/rb/mpd_client)

Yet another Music Player Daemon (MPD) client library written entirely in Ruby.
`mpd_client` is a Ruby port of the [python-mpd](https://github.com/Mic92/python-mpd2) library.

## Installation

Add this line to your application `Gemfile`:

```ruby
gem 'mpd_client'
```

And then execute:

```console
bundle
```

Or install it yourself as:

```console
gem install mpd_client
```

## Usage

All functionality is contained in the `MPD::Client` class. Creating an instance of this class is as simple as:

```ruby
require 'mpd_client'

client = MPD::Client.new
```

Once you have an instance of the `MPD::Client` class, start by connecting to the server:

```ruby
client.connect('localhost', 6600)
```

or Unix domain socket

```ruby
client.connect('/var/run/mpd/socket')
```

The client library can be used as follows:

```ruby
puts client.mpd_version             # print the mpd version
puts client.search('title', 'ruby') # print the result of the command 'search title ruby'
client.close                        # send the close command
client.disconect                    # disconnect from the server
```

Command lists are also supported using `command_list_ok_begin` and `command_list_end`:

```ruby
client.command_list_ok_begin # start a command list
client.update                # insert the update command into the list
client.status                # insert the status command into the list
client.command_list_end      # result will be a Array with the results
```

### Binary responses

Some commands can return binary data.

```ruby
require 'mpd_client'

client = MPD::Client.new
client.connect('localhost', 6600)

if (current_song = client.currentsong)
  data, io = client.readpicture(current_song['file'])
  io # StringIO
  data # => {"size"=>"322860", "type"=>"image/jpeg", "binary"=>"3372"}
  File.write('cover.jpg', io.string)
end
```

The above will locate album art for the current song and save image to `cover.jpg` file.

### Ranges

Some commands(e.g. `move`, `delete`, `load`, `shuffle`, `playlistinfo`) support integer ranges(`[START:END]`) as argument. This is done in `mpd_client` by using two element array:

```ruby
# move the first three songs after the fifth number in the playlist
client.move([0, 3], 5)
```

Second element can be omitted. MPD will assumes the biggest possible number then:

```ruby
# delete all songs from the current playlist, except for the firts ten
client.delete([10,])
```

### Logging

Default logger for all MPD::Client instances:

```ruby
require 'logger'
require 'mpd_client'

MPD::Client.log = Logger.new($stderr)

client = MPD::Client.new
```

Sets the logger used by this instance of MPD::Client:

```ruby
require 'logger'
require 'mpd_client'

client = MPD::Client.new
client.log = Logger.new($stderr)
```

For more information about logging configuration, see [Logger](https://ruby-doc.org/stdlib-2.5.1/libdoc/logger/rdoc/Logger.html)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License and Author

Copyright (c) 2012-2022 by Anton Maminov

This library is distributed under the MIT license.  Please see the LICENSE file.
