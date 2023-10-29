# frozen_string_literal: true

require 'socket'
require 'stringio'
require 'mpd_client/version'

module MPD
  HELLO_PREFIX = 'OK MPD '
  ERROR_PREFIX = 'ACK '
  SUCCESS = "OK\n"
  NEXT = "list_OK\n"

  # MPD changelog: https://github.com/MusicPlayerDaemon/MPD/blob/master/NEWS
  # Protocol: https://mpd.readthedocs.io/en/latest/protocol.html
  COMMANDS = {
    # Status Commands
    'clearerror' => 'fetch_nothing',
    'currentsong' => 'fetch_object',
    'idle' => 'fetch_list',
    'noidle' => '',
    'status' => 'fetch_object',
    'stats' => 'fetch_object',
    # Playback Option Commands
    'consume' => 'fetch_nothing',
    'crossfade' => 'fetch_nothing',
    'mixrampdb' => 'fetch_nothing',
    'mixrampdelay' => 'fetch_nothing',
    'random' => 'fetch_nothing',
    'repeat' => 'fetch_nothing',
    'setvol' => 'fetch_nothing',
    'single' => 'fetch_nothing',
    'replay_gain_mode' => 'fetch_nothing',
    'replay_gain_status' => 'fetch_item',
    'volume' => 'fetch_nothing',
    # Playback Control Commands
    'next' => 'fetch_nothing',
    'pause' => 'fetch_nothing',
    'play' => 'fetch_nothing',
    'playid' => 'fetch_nothing',
    'previous' => 'fetch_nothing',
    'seek' => 'fetch_nothing',
    'seekid' => 'fetch_nothing',
    'seekcur' => 'fetch_nothing',
    'stop' => 'fetch_nothing',
    # Playlist Commands
    'add' => 'fetch_nothing',
    'addid' => 'fetch_item',
    'addtagid' => 'fetch_nothing',
    'cleartagid' => 'fetch_nothing',
    'clear' => 'fetch_nothing',
    'delete' => 'fetch_nothing',
    'deleteid' => 'fetch_nothing',
    'move' => 'fetch_nothing',
    'moveid' => 'fetch_nothing',
    'playlistfind' => 'fetch_songs',
    'playlistid' => 'fetch_songs',
    'playlistinfo' => 'fetch_songs',
    'playlistsearch' => 'fetch_songs',
    'plchanges' => 'fetch_songs',
    'plchangesposid' => 'fetch_changes',
    'prio' => 'fetch_nothing',
    'prioid' => 'fetch_nothing',
    'rangeid' => 'fetch_nothing',
    'shuffle' => 'fetch_nothing',
    'swap' => 'fetch_nothing',
    'swapid' => 'fetch_nothing',
    # Stored Playlist Commands
    'listplaylist' => 'fetch_list',
    'listplaylistinfo' => 'fetch_songs',
    'listplaylists' => 'fetch_playlists',
    'load' => 'fetch_nothing',
    'playlistadd' => 'fetch_nothing',
    'playlistclear' => 'fetch_nothing',
    'playlistdelete' => 'fetch_nothing',
    'playlistmove' => 'fetch_nothing',
    'rename' => 'fetch_nothing',
    'rm' => 'fetch_nothing',
    'save' => 'fetch_nothing',
    # Database Commands
    'count' => 'fetch_object',
    'find' => 'fetch_songs',
    'findadd' => 'fetch_nothing',
    'list' => 'fetch_list',
    'listall' => 'fetch_database',
    'listallinfo' => 'fetch_database',
    'listfiles' => 'fetch_database',
    'lsinfo' => 'fetch_database',
    'search' => 'fetch_songs',
    'searchadd' => 'fetch_nothing',
    'searchaddp1' => 'fetch_nothing',
    'update' => 'fetch_item',
    'rescan' => 'fetch_item',
    'readcomments' => 'fetch_object',
    # Mounts and neighbors
    'mount' => 'fetch_nothing',
    'unmount' => 'fetch_nothing',
    'listmounts' => 'fetch_mounts',
    'listneighbors' => 'fetch_neighbors',
    # Sticker Commands
    'sticker get' => 'fetch_sticker',
    'sticker set' => 'fetch_nothing',
    'sticker delete' => 'fetch_nothing',
    'sticker list' => 'fetch_stickers',
    'sticker find' => 'fetch_songs',
    # Connection Commands
    'close' => '',
    'kill' => '',
    'password' => 'fetch_nothing',
    'ping' => 'fetch_nothing',
    # Audio Output Commands
    'disableoutput' => 'fetch_nothing',
    'enableoutput' => 'fetch_nothing',
    'outputs' => 'fetch_outputs',
    'toggleoutput' => 'fetch_nothing',
    # Reflection Commands
    'config' => 'fetch_item',
    'commands' => 'fetch_list',
    'notcommands' => 'fetch_list',
    'tagtypes' => 'fetch_list',
    'urlhandlers' => 'fetch_list',
    'decoders' => 'fetch_plugins',
    # Client To Client
    'subscribe' => 'fetch_nothing',
    'unsubscribe' => 'fetch_nothing',
    'channels' => 'fetch_list',
    'readmessages' => 'fetch_messages',
    'sendmessage' => 'fetch_nothing'
  }.freeze

  # The `MPD::Client` is used for interactions with a MPD server.
  #
  # Example:
  #
  # ```ruby
  # require 'mpd_client'
  # require 'logger'
  #
  # client = MPD::Client.new
  # client.log = Logger.new($stderr)
  # client.connect('/var/run/mpd/socket')
  # ```
  class Client
    attr_reader :mpd_version

    class << self
      # Default logger for all `MPD::Client`` instances
      #
      # ```ruby
      # MPD::Client.log = Logger.new($stderr)
      # ```
      attr_accessor :log

      def connect(host = 'localhost', port = 6600)
        client = MPD::Client.new
        client.connect(host, port)

        client
      end

      def add_command(name, retval)
        escaped_name = name.tr(' ', '_')

        define_method escaped_name.to_sym do |*args|
          ensure_connected

          execute(name, *args, retval)
        end
      end

      def remove_command(name)
        raise "Can't remove not existent '#{name}' command" unless method_defined? name.to_sym

        remove_method name.to_sym
      end
    end

    def initialize
      @mutex = Mutex.new
      reset
    end

    def connect(host = 'localhost', port = 6600)
      @host = host
      @port = port

      reconnect
    end

    def reconnect
      log&.info("MPD (re)connect #{@host}, #{@port}")

      @socket =
        if @host.start_with?('/')
          UNIXSocket.new(@host)
        else
          TCPSocket.new(@host, @port)
        end

      hello
      @connected = true
    end

    def disconnect
      log&.info('MPD disconnect')
      @socket.close
      reset
    end

    def reset
      @mpd_version = nil
      @command_list = nil
      @socket = nil
      @log = nil
      @connected = false
    end

    def connected?
      @connected
    end

    # https://www.musicpd.org/doc/protocol/command_lists.html
    def command_list_ok_begin
      raise 'Already in command list' unless @command_list.nil?

      write_command('command_list_ok_begin')

      @command_list = []
    end

    def command_list_end
      raise 'Not in command list' if @command_list.nil?

      write_command('command_list_end')

      fetch_command_list
    end

    # The current logger. If no logger has been set MPD::Client.log is used
    def log
      @log || MPD::Client.log
    end

    # Sets the +logger+ used by this instance of MPD::Client
    attr_writer :log

    def albumart(uri)
      fetch_binary(StringIO.new, 0, 'albumart', uri)
    end

    def readpicture(uri)
      fetch_binary(StringIO.new, 0, 'readpicture', uri)
    end

    private

    def ensure_connected
      raise 'Please connect to MPD server' unless connected?
    end

    def execute(command, *, retval)
      @mutex.synchronize do
        write_command(command, *)

        if @command_list.nil?
          eval retval
        else
          @command_list << retval
        end
      end
    end

    def write_line(line)
      begin
        @socket.puts line
      rescue Errno::EPIPE
        reconnect
        @socket.puts line
      end

      @socket.flush
    end

    def write_command(command, *args)
      parts = [command]

      args.each do |arg|
        line =
          if arg.is_a?(Array)
            arg.size == 1 ? "\"#{arg[0].to_i}:\"" : "\"#{arg[0].to_i}:#{arg[1].to_i}\""
          else
            "\"#{escape(arg)}\""
          end

        parts << line
      end

      log&.debug("Calling MPD: #{parts.join(' ')}")
      write_line(parts.join(' '))
    end

    def read_line
      line = @socket.gets

      raise 'Connection lost while reading line' unless line.end_with?("\n")

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

      line
    end

    def read_pair
      line = read_line

      return if line.nil?

      line.split(': ', 2)
    end

    def read_pairs
      result = []

      pair = read_pair

      while pair
        result << pair
        pair = read_pair
      end

      result
    end

    def fetch_item
      pairs = read_pairs

      return nil if pairs.size != 1

      pairs[0][1]
    end

    def fetch_nothing
      line = read_line

      raise "Got unexpected value: #{line}" unless line.nil?
    end

    def fetch_list
      result = []
      seen = nil

      read_pairs.each do |key, value|
        value = value.chomp.force_encoding('utf-8')

        if key != seen
          raise "Expected key '#{seen}', got '#{key}'" unless seen.nil?

          seen = key
        end

        result << value
      end

      result
    end

    def fetch_objects(delimeters = [])
      result = []
      obj = {}

      read_pairs.each do |key, value|
        key = key.downcase
        value = value.chomp.force_encoding('utf-8')

        if delimeters.include?(key)
          result << obj unless obj.empty?
          obj = {}
        elsif obj.include?(key)
          obj[key] << value
        end

        obj[key] = value
      end

      result << obj unless obj.empty?

      result
    end

    def fetch_object
      objs = fetch_objects

      objs ? objs[0] : {}
    end

    def fetch_binary(io = StringIO.new, offset = 0, *)
      data = {}

      @mutex.synchronize do
        write_command(*, offset)

        binary = false

        read_pairs.each do |item|
          if binary
            io << item.join(': ')
            next
          end

          key = item[0]
          value = item[1].chomp

          binary = (key == 'binary')

          data[key] = value
        end
      end

      size = data['size'].to_i
      binary = data['binary'].to_i

      next_offset = offset + binary

      return [data, io] if next_offset >= size

      io.seek(-1, IO::SEEK_CUR)

      fetch_binary(io, next_offset, *)
    end

    def fetch_changes
      fetch_objects(['cpos'])
    end

    def fetch_songs
      fetch_objects(['file'])
    end

    def fetch_mounts
      fetch_objects(['mount'])
    end

    def fetch_neighbors
      fetch_objects(['neighbor'])
    end

    def fetch_messages
      fetch_objects('channel')
    end

    def fetch_outputs
      fetch_objects(['outputid'])
    end

    def fetch_plugins
      fetch_objects(['plugin'])
    end

    def fetch_database
      fetch_objects(%w[file directory playlist])
    end

    def fetch_playlists
      fetch_objects(['playlist'])
    end

    def fetch_stickers
      result = []

      read_pairs.each do |_key, sticker|
        value = sticker.split('=', 2)
        raise "Could now parse sticker: #{sticker}" if value.size < 2

        result << Hash[*value]
      end

      result
    end

    def fetch_sticker
      fetch_stickers[0]
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

      result
    end

    def hello
      line = @socket.gets

      raise 'Connection lost while reading MPD hello' unless line.end_with?("\n")

      line.chomp!

      raise "Got invalid MPD hello: #{line}" unless line.start_with?(HELLO_PREFIX)

      @mpd_version = line[/#{HELLO_PREFIX}(.*)/, 1]
    end

    def escape(text)
      text.to_s.gsub('\\', '\\\\').gsub('"', '\\"')
    end
  end
end

MPD::COMMANDS.each_pair do |name, callback|
  MPD::Client.add_command(name, callback)
end
