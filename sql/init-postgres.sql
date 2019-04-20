CREATE TABLE IF NOT EXISTS users (
       username varchar(32) primary key,
       password varchar(128) not null,
       balance integer not null,
       created timestamp not null default CURRENT_TIMESTAMP);


CREATE TABLE IF NOT EXISTS categories (
       id serial primary key,
       income boolean not null,
       catename varchar(32) not null,
       username varchar(32) not null references users(username),
       parent_tag_id integer
);

CREATE TABLE IF NOT EXISTS book (
       id bigserial primary key,
       income boolean not null,
       title varchar(256) not null,
       record_user varchar(32) not null references users(username),
       t_year smallint not null,
       t_month smallint not null,
       t_day smallint not null,
       val integer not null,
       comment text,
       cate_id integer not null references categories(id)
);
