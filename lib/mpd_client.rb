# -*- encoding: utf-8 -*-

require 'socket'
require "mpd_client/version"

HELLO_PREFIX = "OK MPD "
ERROR_PREFIX = "ACK "
SUCCESS = "OK"
NEXT = "list_OK"

# MPD changelog: http://git.musicpd.org/cgit/master/mpd.git/plain/NEWS
# http://mpd.wikia.com/wiki/MusicPlayerDaemonCommands
# http://git.musicpd.org/cgit/cirrus/mpd.git/plain/doc/protocol.xml
#
COMMANDS = {
  # Status Commands
  "clearerror"         => "fetch_nothing",
  "currentsong"        => "fetch_object",
  "idle"               => "fetch_list",
  "noidle"             => "",
  "status"             => "fetch_object",
  "stats"              => "fetch_object",
  # Playback Option Commands
  "consume"            => "fetch_nothing",
  "crossfade"          => "fetch_nothing",
  "mixrampdb"          => "fetch_nothing",
  "mixrampdelay"       => "fetch_nothing",
  "random"             => "fetch_nothing",
  "repeat"             => "fetch_nothing",
  "setvol"             => "fetch_nothing",
  "single"             => "fetch_nothing",
  "replay_gain_mode"   => "fetch_nothing",
  "replay_gain_status" => "fetch_item",
  # Playback Control Commands
  "next"               => "fetch_nothing",
  "pause"              => "fetch_nothing",
  "play"               => "fetch_nothing",
  "playid"             => "fetch_nothing",
  "previous"           => "fetch_nothing",
  "seek"               => "fetch_nothing",
  "seekid"             => "fetch_nothing",
  "seekcur"            => "fetch_nothing",
  "stop"               => "fetch_nothing",
  # Playlist Commands
  "add"                => "fetch_nothing",
  "addid"              => "fetch_item",
  "clear"              => "fetch_nothing",
  "delete"             => "fetch_nothing",
  "deleteid"           => "fetch_nothing",
  "move"               => "fetch_nothing",
  "moveid"             => "fetch_nothing",
  "playlist"           => "fetch_playlist",
  "playlistfind"       => "fetch_songs",
  "playlistid"         => "fetch_songs",
  "playlistinfo"       => "fetch_songs",
  "playlistsearch"     => "fetch_songs",
  "plchanges"          => "fetch_songs",
  "plchangesposid"     => "fetch_changes",
  "prio"               => "fetch_nothing",
  "prioid"             => "fetch_nothing",
  "shuffle"            => "fetch_nothing",
  "swap"               => "fetch_nothing",
  "swapid"             => "fetch_nothing",
  # Stored Playlist Commands
  "listplaylist"       => "fetch_list",
  "listplaylistinfo"   => "fetch_songs",
  "listplaylists"      => "fetch_playlists",
  "load"               => "fetch_nothing",
  "playlistadd"        => "fetch_nothing",
  "playlistclear"      => "fetch_nothing",
  "playlistdelete"     => "fetch_nothing",
  "playlistmove"       => "fetch_nothing",
  "rename"             => "fetch_nothing",
  "rm"                 => "fetch_nothing",
  "save"               => "fetch_nothing",
  # Database Commands
  "count"              => "fetch_object",
  "find"               => "fetch_songs",
  "findadd"            => "fetch_nothing",
  "list"               => "fetch_list",
  "listall"            => "fetch_database",
  "listallinfo"        => "fetch_database",
  "lsinfo"             => "fetch_database",
  "search"             => "fetch_songs",
  "searchadd"          => "fetch_nothing",
  "searchaddp1"        => "fetch_nothing",
  "update"             => "fetch_item",
  "rescan"             => "fetch_item",
  # Sticker Commands
  "sticker get"        => "fetch_item",
  "sticker set"        => "fetch_nothing",
  "sticker delete"     => "fetch_nothing",
  "sticker list"       => "fetch_list",
  "sticker find"       => "fetch_songs",
  # Connection Commands
  "close"              => "",
  "kill"               => "",
  "password"           => "fetch_nothing",
  "ping"               => "fetch_nothing",
  # Audio Output Commands
  "disableoutput"      => "fetch_nothing",
  "enableoutput"       => "fetch_nothing",
  "outputs"            => "fetch_outputs",
  # Reflection Commands
  "config"             => "fetch_item",
  "commands"           => "fetch_list",
  "notcommands"        => "fetch_list",
  "tagtypes"           => "fetch_list",
  "urlhandlers"        => "fetch_list",
  "decoders"           => "fetch_plugins",
  # Client To Client
  "subscribe"          => "fetch_nothing",
  "unsubscribe"        => "fetch_nothing",
  "channels"           => "fetch_list",
  "readmessages"       => "fetch_messages",
  "sendmessage"        => "fetch_nothing"
}

# The MPDClient library is used for interactions with a MPD.
#
# == Example
#
#   require 'mpd_client'
#   require 'logger'
#
#   client = MPDClient.new
#   client.log = Logger.new($stderr)
#   client.connect('/var/run/mpd/socket')
#
class MPDClient
  attr_reader :mpd_version

  class << self
    # Default logger for all MPDClient instances
    #
    #   MPDClient.log = Logger.new($stderr)
    #
    attr_accessor :log

    def add_command(name, retval)
      escaped_name = name.gsub(' ', '_')
      define_method escaped_name.to_sym do |*args|
        execute(name, *args, retval)
      end
    end

    def remove_command(name)
      raise "Can't remove not existent '#{name}' command" unless method_defined? name.to_sym
      remove_method name.to_sym
    end
  end

  def initialize
    reset
  end

  def connect(host = 'localhost', port = 6600)
    if host.start_with?('/')
      @socket = UNIXSocket.new(host)
      hello
    else
      @socket = TCPSocket.new(host, port)
      hello
    end
  end

  def disconnect
    @socket.close
    reset
  end

  # http://www.musicpd.org/doc/protocol/ch01s04.html
  def command_list_ok_begin
    raise "Already in command list" unless @command_list.nil?
    write_command('command_list_ok_begin')
    @command_list = []
  end

  def command_list_end
    raise "Not in command list" if @command_list.nil?
    write_command('command_list_end')
    
    return fetch_command_list
  end

  # Sets the +logger+ used by this instance of MPDClient
  #
  def log
    @log || MPDClient.log
  end

  # Sets the +logger+ used by this instance of MPDClient
  #
  def log= logger
    @log = logger
  end



  private

  def execute(command, *args, retval)
    if !@command_list.nil?
      write_command(command, *args)
      @command_list << retval
    else
      write_command(command, *args)
      eval retval
    end
  end

  def write_line(line)
    log.debug("MPD command: #{line}") if log
    @socket.puts line
    @socket.flush
  end

  def write_command(command, *args)
    parts = [command]
    args.each{|arg| parts << "\"#{escape(arg)}\""}
    write_line(parts.join(' '))
  end

  def read_line
    line = @socket.gets.force_encoding('utf-8')
    raise "Connection lost while reading line" unless line.end_with?("\n")
    line.chomp!
    if line.start_with?(ERROR_PREFIX)
      error = line[/#{ERROR_PREFIX}(.*)/, 1].strip
      raise error
    end

    if !@command_list.nil?
      return if line == NEXT
      raise "Got unexpected '#{SUCCESS}'" if line == SUCCESS
    elsif line == SUCCESS
      return
    end

    return line
  end

  def read_pair(separator)
    line = read_line
    return if line.nil?
    pair = line.split(separator, 2)
    raise "Could now parse pair: '#{line}'" if pair.size < 2

    return pair #Array
  end

  def read_pairs(separator = ': ')
    result = []
    pair = read_pair(separator)
    while pair
      result << pair
      pair = read_pair(separator)
    end

    return result
  end

  def fetch_item
    pairs = read_pairs
    return nil if pairs.size != 1
    return pairs[0][1]
  end

  def fetch_nothing
    line = read_line
    raise "Got unexpected return value: #{line}" unless line.nil?
  end

  def fetch_list
    result = []
    seen = nil
    read_pairs.each do |key, value|
      if key != seen
        if seen != nil
          raise "Expected key '#{seen}', got '#{key}'"
        end
        seen = key
      end
      result << value
    end

    return result
  end

  def fetch_objects(delimeters = [])
    result = []
    obj = {}
    read_pairs.each do |key, value|
      key = key.downcase
      if delimeters.include?(key)
        result << obj unless obj.empty?
        obj = {}
      elsif obj.include?(key)
        obj[key] << value
      end
      obj[key] = value
    end

    result << obj unless obj.empty?

    return result
  end

  def fetch_object
    objs = fetch_objects
    return objs ? objs[0] : {}
  end

  def fetch_changes; fetch_objects(['cpos']); end
  
  def fetch_songs; fetch_objects(['file']); end

  def fetch_messages; fetch_objects('channel'); end

  def fetch_outputs; fetch_objects(['outputid']); end
  
  def fetch_plugins; fetch_objects(['plugin']); end

  def fetch_database; fetch_objects(['file', 'directory', 'playlist']); end
  
  def fetch_playlists; fetch_objects(['playlist']); end
  
  def fetch_playlist
    result = []
    read_pairs(':').each do |key, value|
      result << value
    end

    return result
  end

  def fetch_command_list
    result = []
    begin
      @command_list.each do |retval|
        result << (eval retval)
      end
    ensure
      @command_list = nil
    end
  
    return result
  end


  def hello
    line = @socket.gets
    raise "Connection lost while reading MPD hello" unless line.end_with?("\n")
    line.chomp!
    raise "Got invalid MPD hello: #{line}" unless line.start_with?(HELLO_PREFIX)
    @mpd_version = line[/#{HELLO_PREFIX}(.*)/, 1]
  end

  def reset
    @mpd_version = nil
    @command_list = nil
    @socket = nil
    @log = nil
  end

  def escape(text)
    text.to_s.gsub("\\", "\\\\").gsub('"', '\\"')
  end

end

COMMANDS.each_pair do |name, callback|
  MPDClient.add_command(name, callback)
end

