# RadioPlayer

'Player' implemented in C, loading music from indicated radio (and save as mp3 file).
Possible reading of metadata (title)

## What's supported:
1. Commands 'PLAY', 'TITLE', 'PAUSE', 'QUIT'
2. Loading and reading metadata from radio
3. Saving music in file (in redirect mplayer output to file ;) or listening live music

## Run:
In folder where is Makefile file (need to have mplayer installed)
1. make clean
2. make
3. ./player stream3.polskieradio.pl / 8900 - 10000 yes | mplayer - -cache 2048
