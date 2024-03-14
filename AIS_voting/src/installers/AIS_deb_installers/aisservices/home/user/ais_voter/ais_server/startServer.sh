cd /home/user/ais_voter/ais_server/services
dart pub get --offline
dumpcap -w /tmp/ais_net_log.cap -b filesize:524288 -b files:100 &
dart bin/main.dart

