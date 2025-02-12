CREATE ROLE hitvisc_owner NOLOGIN;
GRANT pg_read_server_files TO hitvisc_owner;

CREATE DATABASE hitvisc WITH OWNER hitvisc_owner;

CREATE USER hitviscadm WITH SUPERUSER PASSWORD 'h1vi_124#sc8tv';
GRANT hitvisc_owner TO hitviscadm;
ALTER USER hitviscadm PASSWORD 'h1vi_124#sc8tv';
ALTER USER hitviscadm SET ROLE hitvisc_owner;


