--------------------------------------------------------------------------------
-- Создание схемы
CREATE SCHEMA docking_data;
--------------------------------------------------------------------------------

CREATE TABLE docking_data.target
(
    id    INTEGER,
    name  VARCHAR(128)
);

CREATE UNIQUE INDEX idx_target_id ON docking_data.target(id);
CREATE UNIQUE INDEX idx_target_name ON docking_data.target(name);

--------------------------------------------------------------------------------

CREATE TABLE docking_data.pack
(
    id    INTEGER,
    name  VARCHAR(128)
);

CREATE UNIQUE INDEX idx_pack_id ON docking_data.pack(id);
CREATE UNIQUE INDEX idx_pack_name ON docking_data.pack(name);

--------------------------------------------------------------------------------

CREATE TABLE docking_data.ligand
(
    id        INTEGER,
    pack_id   INTEGER,
    name      VARCHAR(128)
);

CREATE UNIQUE INDEX idx_ligand_id ON docking_data.ligand(id);
CREATE INDEX idx_ligand_pack_id ON docking_data.ligand(pack_id);
CREATE UNIQUE INDEX idx_ligand_name ON docking_data.ligand(name);

--------------------------------------------------------------------------------

CREATE TABLE docking_data.workunit
(
    id        INTEGER,
    pack_id   INTEGER,
    target_id INTEGER,
    name      VARCHAR(128)
);

--------------------------------------------------------------------------------

CREATE TABLE docking_data.result_space
(
    id        INTEGER,
    name      VARCHAR(128),
    directory VARCHAR(1024)
);

--------------------------------------------------------------------------------

CREATE TABLE docking_data.docking_file
(
    id              INTEGER,
    result_space_id INTEGER,
    full_name       VARCHAR(1024),
    max_records     INTEGER,
    last_record     INTEGER
);

--------------------------------------------------------------------------------

CREATE TABLE docking_data.docking_result
(
    target_id       INTEGER,
    workunit_id     INTEGER,
    ligand_id       INTEGER,
    score           NUMERIC(8, 4),
    docking_file_id INTEGER,
    file_record     INTEGER,
    file_position   BIGINT
)
PARTITION BY LIST(target_id);

CREATE TABLE docking_data.docking_result_prt_default
    PARTITION OF docking_data.docking_result
    DEFAULT;

--------------------------------------------------------------------------------

CREATE SEQUENCE docking_data.seq_workunit_id INCREMENT BY 1 MINVALUE 1 NO MAXVALUE START WITH 1;
CREATE SEQUENCE docking_data.seq_docking_file_id INCREMENT BY 1 MINVALUE 1 NO MAXVALUE START WITH 1;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION docking_data.GetDockingFile(pi_ResultSpace VARCHAR) RETURNS TABLE(FILE_ID INTEGER, FILE_FULL_NAME VARCHAR, LAST_RECORD INTEGER)
    LANGUAGE PLPGSQL AS
$$
DECLARE
    MAX_FILE_RECORDS CONSTANT INTEGER := 32*1024*1024;

    availableFiles   INTEGER;
    directoryPath    VARCHAR(1024);    
    fileId           INTEGER;
    fileNumber       INTEGER;
    fileFullName     VARCHAR(1024);
    fileShortName    VARCHAR(1024);
    filesCount       INTEGER;
    fileLastRecord   INTEGER;
    resultSpaceCount INTEGER;
    resultSpaceId    INTEGER;
BEGIN
    -- Проверка существования Result Space
    SELECT COUNT(*)
      INTO resultSpaceCount
      FROM RESULT_SPACE
     WHERE NAME = pi_ResultSpace;

    -- Указание на файл в пространстве хранения результатов
    IF resultSpaceCount > 0 THEN
        -- Ищем существующий файл или же создаём новый
            -- Поиск подходящих существующих файлов
            SELECT COUNT(*) AS AVAILABLE_FILES
              INTO availableFiles
              FROM RESULT_SPACE
              JOIN DOCKING_FILE ON DOCKING_FILE.RESULT_SPACE_ID = RESULT_SPACE.ID
             WHERE RESULT_SPACE.NAME = pi_ResultSpace AND DOCKING_FILE.LAST_RECORD < DOCKING_FILE.MAX_RECORDS;

        -- Обработка результатов поиска файлов
        IF availableFiles > 0 THEN
            -- Считываем данные об уже существующем, подходящим файле
            SELECT DOCKING_FILE.ID, DOCKING_FILE.FULL_NAME, DOCKING_FILE.LAST_RECORD
              INTO fileId, fileFullName, fileLastRecord
              FROM RESULT_SPACE
              JOIN DOCKING_FILE ON DOCKING_FILE.RESULT_SPACE_ID = RESULT_SPACE.ID
             WHERE RESULT_SPACE.NAME = pi_ResultSpace AND DOCKING_FILE.LAST_RECORD < DOCKING_FILE.MAX_RECORDS
             ORDER BY ID
             LIMIT 1;
        ELSE
            -- Создаём запись о новом файле
                -- Считываем идентификатор пространства (Result Space-а)
                SELECT ID, DIRECTORY
                  INTO resultSpaceId, directoryPath
                  FROM RESULT_SPACE
                 WHERE NAME = pi_ResultSpace;

                -- Считаем число уже созданных файлов
                SELECT COUNT(*) INTO filesCount FROM DOCKING_FILE WHERE RESULT_SPACE_ID = resultSpaceId;

                -- Определяем идентификатор файла
                SELECT NEXTVAL('SEQ_DOCKING_FILE_ID') INTO fileId;

                -- Формируем имя файла
                fileShortName := pi_ResultSpace || '_' || TRIM(TO_CHAR(filesCount + 1, '099999')) || '.dat';
                fileFullName := directoryPath || '/' || fileShortName;

                -- Выставляем счётчик записей в файле в ноль
               fileLastRecord := 0;
              
                -- Вставляем запись в таблицу DOCKING_FILE
                INSERT INTO DOCKING_FILE(ID, RESULT_SPACE_ID, FULL_NAME, MAX_RECORDS, LAST_RECORD)
                VALUES (fileId, resultSpaceId, fileFullName, MAX_FILE_RECORDS, fileLastRecord);
        END IF;
    ELSE
        RAISE EXCEPTION 'Result Space with name ''%'' does not exist.', pi_ResultSpace;
    END IF;

    RETURN QUERY SELECT fileId, fileFullName, fileLastRecord;   
END;
$$
