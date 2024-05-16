const APP_NAME = 'Сервер АИС голосования';
const ADDRESS = '192.168.0.104';
const HTTP_SERVER_PORT = 27153;
const WEB_SOCKET_PORT = 27154;
const NTP_SERVER = '192.168.0.104';

const PSQL_SERVER = 'localhost';
const PSQL_PORT = 5432;
const PSQL_DATABASE = 'ais_novgorod_0430';
const PSQL_USER = 'postgres';
const PSQL_PASSWORD = 'postgres';

const USE_CONNECTION_QUEUE = false;
const CONNECTION_INTERVAL = 1000;

const STATE_INTERVAL = 1000;
const CLIENT_PING_INTERVAL = 1000;

const VISSONIC_MODULE_PATH =
    '/home/user/Desktop/AIS/AIS_voter_Novgorod/AIS_voting/src/services/external_resources/ais_vissonic_client.sh';
const BACKUP_DB_FOLDER =
    '/home/user/Desktop/AIS_voter/AIS_voting/src/services/backup_db/';

const ENABLE_LOG = true;
