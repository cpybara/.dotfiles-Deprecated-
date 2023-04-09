#!/bin/bash

CURRENT_SONG=""
while true; do
    if ! pgrep -x "spotify" > /dev/null; then
        pkill -f "spotify-notify.sh"
    fi
    
    NEW_SONG=$(playerctl -p spotify metadata artist)$(playerctl -p spotify metadata title)$(playerctl -p spotify status)
    if [[ $NEW_SONG != $CURRENT_SONG ]]; then
        CURRENT_SONG=$NEW_SONG

        SPOTIFY_STATUS=$(playerctl -p spotify status 2>&1)
        
        if [[ $SPOTIFY_STATUS == "Playing" ]]; then
            ARTIST=$(playerctl -p spotify metadata artist)
            TRACK=$(playerctl -p spotify metadata title)
            ALBUM=$(playerctl -p spotify metadata album)
            COVER=$(playerctl -p spotify metadata mpris:artUrl | sed 's/open.spotify.com/i.scdn.co/g')
            TMP_COVER="/tmp/spotify_cover.jpg"

            # Download and save the cover image
            ffmpeg -loglevel 0 -y -i "$COVER" -vf "scale=128:128" "$TMP_COVER"

            # Send the notification
            dunstify -a "Spotify" -u low -i "$TMP_COVER" "$TRACK" "$ARTIST - $ALBUM"

            # Remove the temporary cover image
            rm "$TMP_COVER"
        else
            dunstify -a "Spotify" -i "~/.local/share/icons/candy-icons/apps/scalable/spotify.svg" "Playback is paused."
        fi
    fi
    sleep 1
done
