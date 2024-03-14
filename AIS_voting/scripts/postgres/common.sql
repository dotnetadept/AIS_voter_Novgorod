--Dump dp as script
pg_dump -h localhost -U postgres -F p -f /home/vladimir/Desktop/dump.txt AIS_voter

--Load table data from .csv
copy public._user(secondname,firstname,lastname,login,password) FROM '//home/vladimir/Desktop/sql_test/FIO.csv' DELIMITER ';' CSV
