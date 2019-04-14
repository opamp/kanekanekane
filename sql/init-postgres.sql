CREATE TABLE IF NOT EXISTS users (
       username varchar(32) primary key,
       password varchar(128) not null,
       created timestamp not null default CURRENT_TIMESTAMP);
