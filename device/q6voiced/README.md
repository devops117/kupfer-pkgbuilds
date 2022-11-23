# Using q6voiced
* a user systemd service is installed called q6voiced - enable and start it.
* `aplay -l` and `arecord -l` will display a card/device combination - on Poco this is "VoiceCall" - for use in /etc/conf.d/q6voiced.conf: do this before trying to start the service or it will fail - use `journalctl --user -u q6voiced` to inspect the startup - it should show that it is using the card/device combo you have chosen (or failed to start)


# Troubleshooting
* Use `journalctl --user` as above
* try restarting PulseAudio user service as well as q6voiced
* try doing a recording with arecord (I had to use `-f SE24_LE` to get anything from it - and it was a different card/device combo than above, but it demonstrates alsa is installed and working OK)
* check these files exist and run the .sh manually after you stop the user service if you want to see things as they happen
  - /etc/conf.d/q6voiced (should be installed by the beryllium device PKGBUILD)
  - /usr/bin/q6voiced
  - /usr/lib/systemd/user/q6voiced.service

