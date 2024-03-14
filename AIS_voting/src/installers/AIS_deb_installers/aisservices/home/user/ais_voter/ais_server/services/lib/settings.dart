const APP_NAME = 'Сервер АИС голосования';
const ADDRESS = '192.168.0.104';
const HTTP_SERVER_PORT = 27153;
const WEB_SOCKET_PORT = 27154;
const NTP_SERVER = 'pool.ntp.org';

const PSQL_SERVER = 'localhost';
const PSQL_PORT = 5432;
const PSQL_DATABASE = 'AIS_voter';
const PSQL_USER = 'postgres';
const PSQL_PASSWORD = 'postgres';

const STATE_INTERVAL = 1000;
const CONNECTION_INTERVAL = 1000;
const CLIENT_PING_INTERVAL = 1000;
const FILE_SENT_INTERVAL = 3000;
const FILE_SENT_QUEUE_SIZE = 3;

const VISSONIC_MODULE_PATH =
    '/home/vladimir/Desktop/AIS_voter/src/clients/vissonic_client/bin/';
