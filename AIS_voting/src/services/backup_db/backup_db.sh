#!/bin/bash
echo -e "PASSWORD_SUDO" | PGPASSWORD="postgres" sudo -S -u postgres pg_dump ais_novgorod | gzip > "backup_db/AIS_Novgorod_db `date '+%Y-%m-%d %H:%M:%S'`.gzip"
