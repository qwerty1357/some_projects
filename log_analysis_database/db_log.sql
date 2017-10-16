SET LINESIZE 300;


DROP SEQUENCE user_id_seq;
DROP SEQUENCE logs_id_seq;

DROP TABLE LOGS;
DROP TABLE USERS;
DROP TABLE UPLOADS_HISTORY;

DROP PROCEDURE add_log;
DROP PROCEDURE remove_logs;
DROP PROCEDURE update_history;

DROP FUNCTION logs_in_database;
DROP FUNCTION add_user;
DROP FUNCTION number_of_logs;
DROP FUNCTION number_of_files;
DROP FUNCTION number_of_users;


CREATE TABLE LOGS
    (
        ID      INTEGER NOT NULL,
        LOG_TIME        NUMBER NOT NULL,
        DEVICE_NAME     VARCHAR2 (150),
        MESSAGE       VARCHAR2 (150),
        COMPUTER_NAME       VARCHAR2 (20) NOT NULL
    );


CREATE TABLE USERS
    (
        ID      INTEGER NOT NULL,
        NAME    VARCHAR2 (20) NOT NULL,
        SURNAME    VARCHAR2 (20) NOT NULL,
        LOGIN    VARCHAR2 (20) NOT NULL
    );


CREATE TABLE UPLOADS_HISTORY
    (
        UPLOAD_USER_LOGIN    VARCHAR2 (20) NOT NULL,
        UPLOAD_TIME    TIMESTAMP NOT NULL,
        COMPUTER_NAME    VARCHAR2 (20) NOT NULL
    );



CREATE SEQUENCE user_id_seq
START WITH 10000
INCREMENT BY 1;


CREATE OR REPLACE TRIGGER user_id_trigger
BEFORE INSERT ON USERS
FOR EACH ROW
BEGIN
  SELECT user_id_seq.nextval INTO :NEW.id FROM dual;
END;
/


CREATE SEQUENCE logs_id_seq
START WITH 20000
INCREMENT BY 1;


CREATE OR REPLACE TRIGGER logs_id_trigger
BEFORE INSERT ON LOGS
FOR EACH ROW
BEGIN
  SELECT logs_id_seq.nextval INTO :NEW.id FROM dual;
END;
/


CREATE OR REPLACE FUNCTION add_user(n IN varchar2, surn IN varchar2, l IN varchar2)
    RETURN INTEGER AS
    counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO counter FROM users WHERE login = l;
    IF counter > 0 THEN
        RETURN 0;
    ELSE
        INSERT INTO USERS ("NAME", "SURNAME", "LOGIN") VALUES (n, surn, l);
        RETURN 1;
    END IF;
END add_user;
/


CREATE OR REPLACE PROCEDURE add_log(d IN number, d_name IN varchar2, msg IN varchar2, comp IN varchar2) IS
BEGIN
    INSERT INTO LOGS ("LOG_TIME", "DEVICE_NAME", "MESSAGE", "COMPUTER_NAME") VALUES (d, d_name, msg, comp);
END;
/


CREATE OR REPLACE FUNCTION logs_in_database(comp IN VARCHAR2)
    RETURN INTEGER AS
    counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO counter FROM logs WHERE computer_name = comp;
    IF counter > 0 THEN
        RETURN 1;
    END IF;
    RETURN 0;
END logs_in_database;
/


CREATE OR REPLACE FUNCTION number_of_logs
    RETURN NUMBER AS
    counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO counter FROM logs;
    RETURN counter;
END number_of_logs;
/


CREATE OR REPLACE FUNCTION number_of_files
    RETURN NUMBER AS
    counter NUMBER;
BEGIN
    SELECT COUNT(DISTINCT computer_name) INTO counter FROM logs;
    RETURN counter;
END number_of_files;
/


CREATE OR REPLACE FUNCTION number_of_users
    RETURN NUMBER AS
    counter NUMBER;
BEGIN
    SELECT COUNT(login) INTO counter FROM users;
    RETURN counter;
END number_of_users;
/


CREATE OR REPLACE PROCEDURE remove_logs(comp IN VARCHAR2) IS
BEGIN
    DELETE FROM logs WHERE computer_name = comp;
END;
/


CREATE OR REPLACE PROCEDURE update_history(user_login IN varchar2, comp_name IN varchar2) IS
    curr_timestamp TIMESTAMP(6) := SYSTIMESTAMP;
BEGIN
    INSERT INTO UPLOADS_HISTORY VALUES (user_login, curr_timestamp, comp_name);
END;
/




INSERT INTO USERS ("NAME", "SURNAME", "LOGIN") VALUES ('jan', 'kowalski', 'l234');
INSERT INTO USERS ("NAME", "SURNAME", "LOGIN") VALUES ('adam', 'kowalski', 'login2312');
INSERT INTO USERS ("NAME", "SURNAME", "LOGIN") VALUES ('tom', 'kowalski', 'ladkjslkd');

INSERT INTO USERS ("NAME", "SURNAME", "LOGIN") VALUES ('tom', 'kowalski', 'l    adkjslkd111111');

INSERT INTO USERS ("NAME", "SURNAME", "LOGIN") VALUES ('tom', 'kowalski', 'l    adkjslkd2222');

COMMIT;
