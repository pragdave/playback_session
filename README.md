# Playback Session

Takes a session recorded by
[record_session](http://github.com/pragdave/record_session) and plays
it back in a browser window.

# Usage

* Record terminal sessions, and put the resulting files somewhere accessible
  to your browser/server.

* Add empty block elements to your HTML. Use the `data-from` attribute to
  specify the source recording for each.

  ```
  <div class="playback" data-from="recordings/edit-file.recording"></div>
  ```

* Initialize the recordings by calling

  ```
  $(".playback").playback_recording()
  ```

  This can go in a `<script>` tag at the end of the page, or be called
  inside your own Javascript.

# Copyright

Copyright © 2014 Dave Thomas, The Pragmatic Programmers

License: MIT
