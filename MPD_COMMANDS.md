* [Status Commands](#status-commands)
* [Playback Option Commands](#playback-option-commands)
* [Playback Control Commands](#playback-control-commands)
* [Playlist Commands](#playlist-commands)
* [Stored Playlist Commands](#stored-playlist-commands)
* [Database Commands](#database-commands)
* [Mounts and neighbors](#mounts-and-neighbors)
* [Sticker Commands](#sticker-commands)
* [Connection Commands](#connection-commands)
* [Reflection Commands](#reflection-commands)
* [Client to client](#client-to-client)

### Status Commands ###

---
`clearerror => fetch_nothing`

> Clears the current error message in status (this is also accomplished by any command that starts playback).

---
`currentsong => fetch_object`

> Displays the song info of the current song (same song that is identified in status).

---
`idle [SUBSYSTEMS...] => fetch_list`

> Waits until there is a noteworthy change in one or more of MPD's subsystems. As soon as there is one, it lists all changed systems in a line in the format changed: `SUBSYSTEM`, where `SUBSYSTEM` is one of the following:

> * `database`: the song database has been modified after update.
* `update`: a database update has started or finished. If the database was modified during the update, the database event is also emitted.
* `stored_playlist`: a stored playlist has been modified, renamed, created or deleted
* `playlist`: the current playlist has been modified
* `player`: the player has been started, stopped or seeked
* `mixer`: the volume has been changed
* `output`: an audio output has been enabled or disabled
* `options`: options like repeat, random, crossfade, replay gain
* `sticker`: the sticker database has been modified
* `subscription`: a client has subscribed or unsubscribed to a channel
* `message`: a message was received on a channel this client is subscribed to; this event is only emitted when the queue is empty

> While a client is waiting for `idle` results, the server disables timeouts, allowing a client to wait for events as long as mpd runs. The `idle` command can be canceled by sending the command `noidle` (no other commands are allowed). MPD will then leave `idle` mode and print results immediately; might be empty at this time.

> If the optional `SUBSYSTEMS` argument is used, MPD will only send notifications when something changed in one of the specified subsytems.

---
`noidle`

>

---
`status => "fetch_object`

> Reports the current status of the player and the volume level.

> * `volume`: 0-100
* `repeat`: 0 or 1
* `random`: 0 or 1
* `single`: 0 or 1
* `consume`: 0 or 1
* `playlist`: 31-bit unsigned integer, the playlist version number
* `playlistlength`: integer, the length of the playlist
* `state`: play, stop, or pause
* `song`:  playlist song number of the current song stopped on or playing
* `songid`: playlist songid of the current song stopped on or playing
* `nextsong`: playlist song number of the next song to be played
* `nextsongid`: playlist songid of the next song to be played
* `time`: total time elapsed (of current playing/paused song)
* `elapsed`: Total time elapsed within the current song, but with higher resolution.
* `bitrate`: instantaneous bitrate in kbps
* `xfade`: crossfade in seconds
* `mixrampdb`: mixramp threshold in dB
* `mixrampdelay`: mixrampdelay in seconds
* `audio`: sampleRate:bits:channels
* `updating_db`: job id
* `error`: if there is an error, returns message here

---
`stats => "fetch_object`

> Displays statistics.

> * `artists`: number of artists
* `songs`: number of albums
* `uptime`: daemon uptime in seconds
* `db_playtime`: sum of all song times in the db
* `db_update`: last db update in UNIX time
* `playtime`: time length of music played

### Playback Option Commands ###

---
`consume {STATE} => fetch_nothing`

> Sets consume state to `STATE`, `STATE` should be 0 or 1. When consume is activated, each song played is removed from playlist.

---
`crossfade {SECONDS} => fetch_nothing`

> Sets crossfading between songs.

---
`mixrampdb {deciBels} => fetch_nothing`

> Sets the threshold at which songs will be overlapped. Like crossfading but doesn't fade the track volume, just overlaps. The songs need to have MixRamp tags added by an external tool. 0dB is the normalized maximum volume so use negative values, I prefer -17dB. In the absence of mixramp tags crossfading will be used. See http://sourceforge.net/projects/mixramp

---
`mixrampdelay {SECONDS} => fetch_nothing`

> Additional time subtracted from the overlap calculated by `mixrampdb`. A value of "nan" disables MixRamp overlapping and falls back to crossfading.

---
`random {STATE} => fetch_nothing`

> Sets random state to `STATE`, `STATE` should be 0 or 1.

---
`repeat {STATE} => fetch_nothing`

> Sets repeat state to `STATE`, `STATE` should be 0 or 1.

---
`setvol {VOL} => fetch_nothing`

> Sets volume to `VOL`, the range of volume is 0-100.

---
`single {STATE} => fetch_nothing`

> Sets single state to `STATE`, `STATE` should be 0 or 1. When single is activated, playback is stopped after current song, or song is repeated if the 'repeat' mode is enabled.

---
`replay_gain_mode {MODE} => fetch_nothing`

> Sets the replay gain mode. One of `off`, `track`, `album`, `auto`.

> Changing the mode during playback may take several seconds, because the new settings does not affect the buffered data.

> This command triggers the options idle event.

---
`replay_gain_status => fetch_item`

> Prints replay gain options. Currently, only the variable `replay_gain_mode` is returned.

---
`volume {CHANGE} => fetch_nothing`

> Changes volume by amount `CHANGE`.

### Playback Control Commands ###

---
`next => fetch_nothing`

> Plays next song in the playlist.

---
`pause {PAUSE} => fetch_nothing`

> Toggles pause/resumes playing, `PAUSE` is 0 or 1.
> > **Note**. The use of pause command w/o the `PAUSE` argument is deprecated.

---
`play [SONGPOS] => fetch_nothing`

> Begins playing the playlist at song number `SONGPOS`.

---
`playid [SONGID] => fetch_nothing`

> Begins playing the playlist at song `SONGID`.

---
`previous => fetch_nothing`

> Plays previous song in the playlist.

---
`seek {SONGPOS} {TIME} => fetch_nothing`

> Seeks to the position `TIME` (in seconds) of entry `SONGPOS` in the playlist.

---
`seekid {SONGID} {TIME} => fetch_nothing`

> Seeks to the position `TIME` (in seconds) of song `SONGID`.

---
`seekcur {TIME} => fetch_nothing`

> Seeks to the position `TIME` within the current song. If prefixed by '+' or '-', then the time is relative to the current playing position.

---
`stop  => fetch_nothing`

> Stops playing.


### Playlist Commands ###

---
`add {URI} => fetch_nothing`

> Adds the file `URI` to the playlist (directories add recursively). `URI` can also be a single file.

---
`addid {URI} [POSITION] => fetch_item`

> Adds a song to the playlist (non-recursive) and returns the song id.

> `URI` is always a single file or URL.

---
`clear => fetch_nothing`

> Clears the current playlist.

---
`delete [{POS} | {START:END}] => fetch_nothing`

> Deletes a song from the playlist.

---
`deleteid {SONGID} => fetch_nothing`

> Deletes the song `SONGID` from the playlist

---
`move [{FROM} | {START:END}] {TO} => fetch_nothing`

> Moves the song at `FROM` or range of songs at `START:END` to `TO` in the playlist.

---
`moveid {FROM} {TO} => fetch_nothing`

> Moves the song with `FROM` (songid) to `TO` (playlist index) in the playlist. If `TO` is negative, it is relative to the current song in the playlist (if there is one).

---
`playlist => fetch_playlist`

> Displays the current playlist.

> > **Note**: Do not use this, instead use `playlistinfo`.

---
`playlistfind {TAG} {NEEDLE} => fetch_songs`

> Finds songs in the current playlist with strict matching.

---
`playlistid {SONGID} => fetch_songs`

> Displays a list of songs in the playlist. `SONGID` is optional and specifies a single song to display info for.

---
`playlistinfo [[SONGPOS] | [START:END]] => fetch_songs`

> Displays a list of all songs in the playlist, or if the optional argument is given, displays information only for the song `SONGPOS` or the range of songs `START:END`

---
`playlistsearch {TAG} {NEEDLE} => fetch_songs`

> Searches case-sensitively for partial matches in the current playlist.

---
`plchanges {VERSION} => fetch_songs`

> Displays changed songs currently in the playlist since `VERSION`.

> To detect songs that were deleted at the end of the playlist, use `playlistlength` returned by status command.

---
`plchangesposid {VERSION} => fetch_changes`

> Displays changed songs currently in the playlist since `VERSION`. This function only returns the position and the id of the changed song, not the complete metadata. This is more bandwidth efficient.

> To detect songs that were deleted at the end of the playlist, use `playlistlength` returned by status command.

---
`prio {PRIORITY} {START:END...} => fetch_nothing`

> Set the priority of the specified songs. A higher priority means that it will be played first when "random" mode is enabled.

> A priority is an integer between 0 and 255. The default priority of new songs is 0.

---
`prioid {PRIORITY} {ID...} => fetch_nothing`

> Same as `prio`, but address the songs with their id.

---
`rangeid {ID} {START:END} => fetch_nothing`

> Specifies the portion of the song that shall be played. `START` and `END` are offsets in seconds (fractional seconds allowed); both are optional. Omitting both (i.e. sending just ":") means "remove the range, play everything". A song that is currently playing cannot be manipulated this way.

---
`shuffle [START:END] => fetch_nothing`

> Shuffles the current playlist. `START:END` is optional and specifies a range of songs.

---
`swap {SONG1} {SONG2} => fetch_nothing`

> Swaps the positions of `SONG1` and `SONG2`.

---
`swapid {SONG1} {SONG2} => fetch_nothing`

> Swaps the positions of `SONG1` and `SONG2` (both song ids).

---
`addtagid {SONGID} {TAG} {VALUE} => fetch_nothing`

> Adds a `TAG` to the specified `SONGID`. Editing song tags is only possible for remote songs. This change is volatile: it may be overwritten by tags received from the server, and the data is gone when the song gets removed from the queue.

---
`cleartagid {SONGID} [TAG] => fetch_nothing`

> Removes `TAG` from the specified `SONGID`. If `TAG` is not specified, then all tag values will be removed. Editing song tags is only possible for remote songs.

### Stored Playlist Commands ###

Playlists are stored inside the configured playlist directory. They are addressed with their file name (without the directory and without the .m3u suffix).

Some of the commands described in this section can be used to run playlist plugins instead of the hard-coded simple m3u parser. They can access playlists in the music directory (relative path including the suffix) or remote playlists (absolute URI with a supported scheme).

---
`listplaylist {NAME} => fetch_list`

> Lists the songs in the playlist. Playlist plugins are supported.

---
`listplaylistinfo {NAME} => fetch_songs`

> Lists the songs with metadata in the playlist. Playlist plugins are supported.

---
`listplaylists => fetch_playlists`

> Prints a list of the playlist directory.

> After each playlist name the server sends its last modification time as attribute "Last-Modified" in ISO 8601 format. To avoid problems due to clock differences between clients and the server, clients should not compare this value with their local clock.

---
`load {NAME} [START:END] => fetch_nothing`

> Loads the playlist into the current queue. Playlist plugins are supported. A range may be specified to load only a part of the playlist.

---
`playlistadd {NAME} {URI} => fetch_nothing`

> Adds `URI` to the playlist `NAME.m3u`.

> `NAME.m3u` will be created if it does not exist.

---
`playlistclear {NAME} => fetch_nothing`

> Clears the playlist `NAME.m3u`.

---
`playlistdelete {NAME} {SONGPOS} => fetch_nothing`

> Deletes `SONGPOS` from the playlist `NAME.m3u`.

---
`playlistmove {NAME} {SONGID} {SONGPOS} => fetch_nothing`

> Moves `SONGID` in the playlist `NAME.m3u` to the position `SONGPOS`.

---
`rename {NAME} {NEW_NAME} => fetch_nothing`

> Renames the playlist `NAME.m3u` to `NEW_NAME.m3u`.

---
`rm {NAME} => fetch_nothing`

> Removes the playlist `NAME.m3u` from the playlist directory.

---
`save {NAME} => fetch_nothing`

> Saves the current playlist to `NAME.m3u` in the playlist directory.

### Database Commands ###

---
`count {TAG} {NEEDLE} => fetch_object`

> Counts the number of songs and their total playtime in the db matching `TAG` exactly.

---
`find {TYPE} {WHAT} [...] => fetch_songs`

> Finds songs in the db that are exactly `WHAT`. `TYPE` can be any tag supported by MPD, or one of the two special parameters — file to search by full path (relative to database root), and any to match against all available tags. `WHAT` is what to find.

---
`findadd {TYPE} {WHAT} [...] => fetch_nothing`

> Finds songs in the db that are exactly `WHAT` and adds them to current playlist. Parameters have the same meaning as for find.

---
`list {TYPE} [ARTIST] => fetch_list`

> Lists all tags of the specified type. `TYPE` can be any tag supported by MPD or file.

> `ARTIST` is an optional parameter when type is album, this specifies to list albums by an artist.

---
`listall [URI] => fetch_database`

> Lists all songs and directories in `URI`.

---
`listallinfo [URI] => fetch_database`

> Same as `listall`, except it also returns metadata info in the same format as `lsinfo`.

---
`listfiles [URI] => fetch_database`

> Lists the contents of the directory `URI`, including files are not recognized by `MPD`. `URI` can be a path relative to the music directory or an `URI` understood by one of the storage plugins. The response contains at least one line for each directory entry with the prefix `"file: "` or  `"directory: "`, and may be followed by file attributes such as `"Last-Modified"` and `"size"`.

> For example, `smb://SERVER` returns a list of all shares on the given SMB/CIFS server; `nfs://servername/path` obtains a directory listing from the NFS server.

---
`lsinfo [URI] => fetch_database`

> Lists the contents of the directory `URI`.

> When listing the root directory, this currently returns the list of stored playlists. This behavior is deprecated; use `listplaylists` instead.

> Clients that are connected via UNIX domain socket may use this command to read the tags of an arbitrary local file (`URI` beginning with "file:///").

---
`search {TYPE} {WHAT} [...] => fetch_songs`

> Searches for any song that contains `WHAT`. Parameters have the same meaning as for find, except that search is not case sensitive.

---
`searchadd {TYPE} {WHAT} [...] => fetch_nothing`

> Searches for any song that contains `WHAT` in tag `TYPE` and adds them to current playlist.

> Parameters have the same meaning as for `find`, except that search is not case sensitive.

---
`searchaddpl {NAME} {TYPE} {WHAT} [...] => fetch_nothing`

> Searches for any song that contains `WHAT` in tag `TYPE` and adds them to the playlist named `NAME`.

> If a playlist by that name doesn't exist it is created.

> Parameters have the same meaning as for find, except that search is not case sensitive.

---
`update [URI] => fetch_item`

> Updates the music database: find new files, remove deleted files, update modified files.

> `URI` is a particular directory or song/file to update. If you do not specify it, everything is updated.

> Prints "updating_db: JOBID" where JOBID is a positive number identifying the update job. You can read the current job id in the status response.

---
`rescan [URI] => fetch_item`

> Same as `update`, but also rescans unmodified files.

---
`readcomments [URI] => fetch_object`

> Read "comments" (i.e. key-value pairs) from the file specified by `URI`. This `URI` can be a path relative to the music directory or a URL in the form `file:///foo/bar.ogg`.

> The response consists of lines in the form "KEY: VALUE". Comments with suspicious characters (e.g. newlines) are ignored silently.

> The meaning of these depends on the codec, and not all decoder plugins support it.  For example, on Ogg files, this lists the Vorbis comments.

### Mounts and neighbors ###

A "storage" provides access to files in the directory tree. The most basic storage plugin is a "local" storage plugin which accesses the local file system, and there are plugins to access NFS and SMB servers.

Multiple storages can be "mounted" together, similar to the `mount` command on many operationg systems, but without cooperation from the kernel. No superuser privileges are necessary, beause this mapping exists only inside the `MPD` process.

---
`mount {PATH} {URI} => fetch_nothing`

> Mount the specified remote storage `URI` at the given `PATH`

---
`unmount {PATH} => fetch_nothing`

> Unmounts the specified `PATH`

---
`listmounts => fetch_mounts`

> Queries a list of all mounts.  By default, this contains just the configured `music_directory`

---
`listneighbors => fetch_neighbors`

> Queries a list of "neighbors" (e.g. accessible file servers on the local net).  Items on that list may be used with the `mount` command.

### Sticker Commands ###

"Stickers" are pieces of information attached to existing MPD objects (e.g. song files, directories, albums). Clients can create arbitrary name/value pairs. MPD itself does not assume any special meaning in them.

The goal is to allow clients to share additional (possibly dynamic) information about songs, which is neither stored on the client (not available to other clients), nor stored in the song files (MPD has no write access).

Client developers should create a standard for common sticker names, to ensure interoperability.

Objects which may have stickers are addressed by their object type ("song" for song objects) and their URI (the path within the database for songs).

---
`sticker get {TYPE} {URI} {NAME} => fetch_sticker`

> Reads a sticker value for the specified object.

---
`sticker set {TYPE} {URI} {NAME} {VALUE} => fetch_nothing`

> Adds a sticker value to the specified object. If a sticker item with that name already exists, it is replaced.

---
`sticker delete {TYPE} {URI} [NAME] => fetch_nothing`

> Deletes a sticker value from the specified object. If you do not specify a sticker name, all sticker values are deleted.

---
`sticker list {TYPE} {URI} => fetch_stickers`

> Lists the stickers for the specified object.

---
`sticker find {TYPE} {URI} {NAME} => fetch_songs`

> Searches the sticker database for stickers with the specified name, below the specified directory (`URI`). For each matching song, it prints the URI and that one sticker's value.

### Connection Commands ###

---
`close`

> Closes the connection to MPD.

---
`kill`

> Kills MPD.

---
`password {PASSWORD} => fetch_nothing`

> This is used for authentication with the server. `PASSWORD` is simply the plaintext password.

---
`ping => fetch_nothing`

> Does nothing but return "OK".

## Audio Output Commands

---
`disableoutput {ID} => fetch_nothing`

> Turns an output off.

---
`enableoutput {ID} => fetch_nothing`

> Turns an output on.

---
`outputs => fetch_outputs`

> Shows information about all outputs.

---
`toggleoutput {ID} => fetch_nothing`

> Turns an output on or off, depending on the current state.


### Reflection Commands ###

---
`config => fetch_item`

> Dumps configuration values that may be interesting for the client. This command is only permitted to "local" clients (connected via UNIX domain socket).

> The following response attributes are available:

>
| Name 	             | Description                              |
| ------------------ | ---------------------------------------- |
| music_directory    | The absolute path of the music directory |

---
`commands => fetch_list`

> Shows which commands the current user has access to.

---
`notcommands => fetch_list`

> Shows which commands the current user does not have access to.

---
`tagtypes => fetch_list`

> Shows a list of available song metadata.

---
`urlhandlers => fetch_list`

> Gets a list of available URL handlers.

---
`decoders => fetch_plugins`

> Print a list of decoder plugins, followed by their supported suffixes and MIME types.

### Client to client ###

Clients can communicate with each others over "channels". A channel is created by a client subscribing to it. More than one client can be subscribed to a channel at a time; all of them will receive the messages which get sent to it.

Each time a client subscribes or unsubscribes, the global idle event subscription is generated. In conjunction with the channels command, this may be used to auto-detect clients providing additional services.

New messages are indicated by the message idle event.

---
`subscribe {NAME} => fetch_nothing`

> Subscribe to a channel. The channel is created if it does not exist already. The name may consist of alphanumeric ASCII characters plus underscore, dash, dot and colon.

---
`unsubscribe {NAME} => fetch_nothing`

> Unsubscribe from a channel.

---
`channels => fetch_list`

> Obtain a list of all channels. The response is a list of "channel:" lines.

---
`readmessages => fetch_messages`

> Reads messages for this client. The response is a list of "channel:" and "message:" lines.

---
`sendmessage {CHANNEL} {TEXT} => fetch_nothing`

> Send a message to the specified channel.
