# MPDClient

Yet another Music Player Daemon (MPD) client library written entirely in Ruby.
`mpd_client` is a Ruby port of the [python-mpd](https://github.com/Mic92/python-mpd2) library.

## Installation

Add this line to your application `Gemfile`:

```ruby
gem 'mpd_client'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install mpd_client
```

## Usage
All functionality is contained in the `MPDClient` class. Creating an instance of this class is as simple as:

```ruby
client = MPDClient.new
```

Once you have an instance of the `MPDClient` class, start by connecting to the server:

```ruby
client.connect('localhost', 6600)
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
