-- Функция добавления компьютера
CREATE OR REPLACE FUNCTION registry.boinc_host_add(p_boinc_host_id INT, p_boinc_user_id INT, p_host_usage_type CHAR(1))
    RETURNS BOOLEAN
    LANGUAGE PLPGSQL
AS
$$
-- Добавление компьютера в таблицу registry.host
-- Входные параметры:
-- p_boinc_host_id     - Идентификатор компьютера в BOINC-проекте
-- p_boinc_user_id     - Идентификатор пользователя - владельца компьютера в BOINC-проекте
-- p_host_usage_type   - Тип вычислительного ресурса: 'T' - test, 'R' - private, 'P' - public
-- Выходные параметры:
-- l_result            - Флаг добавления новой записи в таблицу registry.host
--
-- Запросом вида INSERT<-SELECT проверяется, что компьютер не был ранее добавлен
--
DECLARE
    l_result         BOOLEAN := FALSE; -- Флаг добавление компьютера в список
    l_processed_rows INT := 0;         -- Число строк обработанных командой вставки нового компьютера
BEGIN
    -- Добавление компьютера, если он отсутствует в списке системы
    WITH host_data AS
    (
        SELECT CASE WHEN host.id IS NULL THEN 'new_host' ELSE 'known_host' END AS host_state,
               host_owner.id AS user_id,
               boinc_host.boinc_host_id
          FROM (SELECT p_boinc_host_id AS boinc_host_id, p_boinc_user_id AS boinc_user_id) boinc_host
          JOIN registry."user" AS host_owner ON host_owner.boinc_user_id = boinc_host.boinc_user_id
          LEFT JOIN registry.host ON host.boinc_host_id = boinc_host.boinc_host_id
    ) 
    INSERT INTO registry.host(id, create_time, user_id, boinc_host_id, host_usage_type) 
    SELECT NEXTVAL('registry.seq_host_id') AS id,
           CURRENT_TIMESTAMP,
           user_id,
           boinc_host_id,
           p_host_usage_type
      FROM host_data
     WHERE host_state = 'new_host';

    -- Считывание результата добавления
    GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
    l_result := l_processed_rows > 0;

    RETURN l_result;
END;
$$;
-- Функция создания задач
CREATE OR REPLACE FUNCTION registry.create_workunits(p_search_id integer, p_first_package_id integer DEFAULT NULL::integer, 
                                                                          p_last_package_id integer DEFAULT NULL::integer)
 RETURNS boolean
 LANGUAGE plpgsql
AS 
$$
-- Создание задач - вставка записей в таблицу workunit
-- Входные параметры:
-- p_search_id           - Идентификатор поиска
-- p_first_package_id    - Идентификатор пакета (из таблицы package), с которого надо начинать создание задач
-- p_last_package_id     - Идентификатор пакета, на котором надо завершать создание задач
-- Выходные параметры:
-- l_result              - Флаг успешного создания набора задач
DECLARE
    l_result                 BOOLEAN := FALSE;         -- Флаг успешного выполнения функции
    l_rows_count             INT := -1;		           -- Число добавленных workunit-ов
    l_docker_id              INT := -1;
    l_docker_last_version_id INT := -1;                -- Идентификатор версии расчётного модуля
    l_generated_state_count  INT := -1;                -- Число строк, соответствующих состоянию "Создана" в справочнике состояний задачи
    l_generated_state_id     INT := -1;                -- Идентификатор состояния задачи "Создана"
BEGIN
	-- Определение версии вычислительного модуля
	SELECT docker_id INTO l_docker_id FROM registry.search WHERE id = p_search_id;
	SELECT id INTO l_docker_last_version_id FROM registry.docker_version 
		WHERE docker_id = l_docker_id ORDER BY version_number DESC LIMIT 1; 	

	  -- Определение идентификатора состояния задачи
	    -- Считываем число записей, соответствующих состоянию задачи "Создана"
		SELECT MAX(id), COUNT(*)
		  INTO l_generated_state_id, l_generated_state_count
		  FROM registry.workunit_state
		 WHERE name = 'GENERATED';
		-- Выводим оповещение, если нужная запись не найдена
	    IF COALESCE(l_generated_state_count, -1) != 1 OR COALESCE(l_generated_state_id, -1) <= 0 THEN
	        RAISE NOTICE 'Cannot found explicit row for workunit status "GENERATED"';    
	    END IF;
	  
	-- Вставка в таблицу workunit строк, соответствующих мишени и пакетам с лигандам из указанного диапазона
	IF l_docker_last_version_id > 0 AND l_generated_state_id > 0 THEN
	
	INSERT INTO registry.workunit(id, create_time, search_id, package_id, docker_version_id, state_id, name)
	    SELECT NEXTVAL('registry.seq_workunit_id') AS id, CURRENT_TIMESTAMP, p_search_id, package.id, l_docker_last_version_id, l_generated_state_id, REPLACE(search.prefix || '_' || library.system_name || '_' || l_docker_last_version_id || '_' || package.id, ' ', '_') AS workunit_name
	      FROM registry.search
	      JOIN registry.target ON target.id = search.target_id
	      JOIN registry.docker ON docker.id = search.docker_id
	      JOIN registry.docker_version ON docker_version.docker_id = docker.id
	      JOIN registry.library ON library.id = search.library_id
	      JOIN registry.package ON package.library_id = library.id
	     WHERE search.id = p_search_id AND docker_version.id = l_docker_last_version_id
	       AND (p_first_package_id IS NULL OR p_first_package_id <= package.id) AND (package.id <= p_last_package_id OR p_last_package_id IS NULL);
	        
	    -- Считывание числа обработанных строк
	    GET DIAGNOSTICS l_rows_count := ROW_COUNT;
	    RAISE NOTICE 'Generated % workunits.', l_rows_count;
	
	    -- Вывешиваем флаг успешного завершения функции
	    l_result := TRUE;   
    ELSE
    	-- Вывешиваем флаг неудачного развершения функции
        l_result := FALSE;
    END IF;
       
	RETURN l_result;
END;
$$;
-- Функция формирования задач
CREATE OR REPLACE FUNCTION registry.create_workunits_old(p_search_id INT, 
                                                     p_first_package_id INT DEFAULT NULL, 
                                                     p_last_package_id INT DEFAULT NULL, 
                                                     p_docker_version DOUBLE PRECISION DEFAULT NULL)
    RETURNS BOOLEAN
    LANGUAGE PLPGSQL
AS
$$
-- Создание задач - вставка записей в таблицу workunit
-- Входные параметры:
-- p_search_id           - Идентификатор поиска
-- p_first_package_id    - Идентификатор пакета (из таблицы package), с которого надо начинать создание задач
-- p_last_package_id     - Идентификатор пакета, на котором надо завершать создание задач
-- p_docker_version      - Номер версии вычислительного модуля, который надо использовать при вычислениях
-- Выходные параметры:
-- l_result              - Флаг успешного создания набора задач
DECLARE
    l_result                BOOLEAN := FALSE;         -- Флаг успешного выполнения функции
    l_rows_count            INT := -1;		      -- Число добавленных workunit-ов
    l_docker_version_count  INT := -1;                -- Число строк с выбираемой версией расчётного модуля
    l_docker_version_id     INT := -1;                -- Идентификатор версии расчётного модуля
    l_docker_last_version   DOUBLE PRECISION := -1.0; -- Номер новейшей версии модуля
    l_generated_state_count INT := -1;                -- Число строк, соответствующих состоянию "Создана" в справочнике состояний задачи
    l_generated_state_id    INT := -1;                -- Идентификатор состояния задачи "Создана"
BEGIN
	-- Определение версии вычислительного модуля
        -- Проверка существования указанной версии вычислительного модуля или, если она не указана, вычисление номера последней версии
    	SELECT COUNT(*), MAX(docker_version.version_number) INTO l_docker_version_count, l_docker_last_version
    	  FROM registry.search
    	  JOIN registry.docker ON docker.id = search.docker_id
    	  JOIN registry.docker_version ON docker_version.id = docker.id
    	 WHERE (p_docker_version IS NOT NULL AND docker_version.version_number = p_docker_version) OR (p_docker_version IS NULL);

    	-- Определение идентификатора версии вычислительного модуля для номера проверенного или определённого выше
    	IF (l_docker_version_count = 1 OR (l_docker_version_count > 1 AND p_docker_version IS NULL)) AND (l_docker_last_version IS NOT NULL AND l_docker_last_version > 0) THEN
	    	SELECT MAX(docker_version.id)
		      INTO l_docker_version_id
		      FROM registry.search
	          JOIN registry.docker ON docker.id = search.docker_id
	          JOIN registry.docker_version ON docker_version.id = docker.id
	         WHERE docker_version.version_number = l_docker_last_version;
	    ELSE
		    RAISE NOTICE 'Appropriate docker module for search with id % and version number % is not found or found more than once.', p_search_id, p_docker_version;
	    END IF;

	   -- Проверка нахождения единственной подходящей версии
	   IF l_docker_version_count IS NULL THEN
	       l_docker_version_id := -1;
	       RAISE NOTICE 'Explicit docker module for search with id % and version number % is not found.', p_search_id, p_docker_version;
	   END IF;
	
	   -- Определение идентификатора состояния задачи
	    -- Считываем число записей, соответствующих состоянию задачи "Создана"
		SELECT MAX(id), COUNT(*)
		  INTO l_generated_state_id, l_generated_state_count
		  FROM registry.workunit_state
		 WHERE name = 'GENERATED';
		-- Выводим оповещение, если нужная запись не найдена
	    IF COALESCE(l_generated_state_count, -1) != 1 OR COALESCE(l_generated_state_id, -1) <= 0 THEN
	        RAISE NOTICE 'Cannot found explicit row for workunit status "GENERATED"';    
	    END IF;
	  
	-- Вставка в таблицу workunit строк, соответствующих мишени и пакетам с лигандами из указанного диапазона
	IF l_docker_version_id > 0 AND l_generated_state_id > 0 THEN
	
	INSERT INTO registry.workunit(id, create_time, search_id, package_id, docker_version_id, state_id, name)
	    SELECT NEXTVAL('registry.seq_workunit_id') AS id, CURRENT_TIMESTAMP, p_search_id, package.id, l_docker_version_id, l_generated_state_id, REPLACE(search.prefix || '_' || library.system_name || '_' || package.id, ' ', '_') AS workunit_name
	      FROM registry.search
	      JOIN registry.target ON target.id = search.target_id
	      JOIN registry.docker ON docker.id = search.docker_id
	      JOIN registry.docker_version ON docker_version.docker_id = docker.id
	      JOIN registry.library ON library.id = search.library_id
	      JOIN registry.package ON package.library_id = library.id
	     WHERE search.id = p_search_id AND docker_version.id = l_docker_version_id
	       AND (p_first_package_id IS NULL OR p_first_package_id <= package.id) AND (package.id <= p_last_package_id OR p_last_package_id IS NULL);
	        
	    -- Считывание числа обработанных строк
	    GET DIAGNOSTICS l_rows_count := ROW_COUNT;
	    RAISE NOTICE 'Generated % workunits.', l_rows_count;
	
	    -- Вывешиваем флаг успешного завершения функции
	    l_result := TRUE;   
    ELSE
    	-- Вывешиваем флаг неудачного развершения функции
        l_result := FALSE;
    END IF;
       
	RETURN l_result;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_target_add(p_name CHARACTER VARYING, p_system_name CHARACTER VARYING, p_description CHARACTER VARYING, p_authors CHARACTER VARYING, p_source CHARACTER VARYING, p_usage_type CHAR(1), p_state CHAR(1))
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление мишени в таблицу registry.target
-- Входные параметры:
-- p_name                - Название мишени
-- p_system_name         - Системное имя мишени
-- p_description         - Описание мишени
-- p_authors             - Авторы мишени
-- p_source              - Источник мишени
-- p_usage_type          - Вид использования ('O' - open, 'R' - restricted, 'P' - private)
-- p_state               - Состояние ('P' - preparing, 'U' - unlocked, 'L' - locked, 'A' - archived)
-- Выходные параметры:
-- l_id                  - Идентификатор добавленной мишени в registry.target
--
DECLARE
    l_result            BOOLEAN := FALSE; -- Флаг успешного добавления мишени
    l_id                INT := -1;        -- Идентификатор новой мишени
    l_processed_rows    INT := 0;         -- Число строк, обработанных командой вставки записи о новой мишени
    l_does_target_exist INT := 0;         -- Флаг проверки существования мишени с таким же именем
BEGIN
    -- Проверка наличия мишени с таким же именем
    SELECT COUNT(*) INTO l_does_target_exist FROM registry.target WHERE name = p_name OR system_name = p_system_name;

    -- Занесение мишени в таблицу, если мишени с таким же именем ещё нет
    IF l_does_target_exist = 0 AND p_name IS NOT NULL AND LENGTH(p_name) > 0 AND p_system_name IS NOT NULL AND LENGTH(p_system_name) > 0 THEN
        -- Добавление мишени
            SELECT NEXTVAL('registry.seq_target_id') INTO l_id;
            -- Вставка записи в таблицу
            INSERT INTO registry.target(id, create_time, name, system_name, description, authors, source, usage_type, state)
            VALUES(l_id, CURRENT_TIMESTAMP, p_name, p_system_name, p_description, p_authors, p_source, p_usage_type, p_state);
            -- Считывание результата добавления
            GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
            l_result := l_processed_rows > 0;
    ELSE
        -- Убираем флаг успешного добавления мишени
        l_result := FALSE;
    END IF;

    IF NOT l_result THEN
        l_id := -1;
    END IF;

    RETURN l_id;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_target_delete(p_id INT)
    RETURNS BOOLEAN
    LANGUAGE PLPGSQL
AS
$$
-- Удаление информации о мишени из таблиц target и target_file если иной связанной с ней информации ещё нет
-- Входные параметры:
-- p_id                  - Идентификатор файла
-- Выходные параметры:
-- l_result              - Флаг успешного удаления информации о мишени
DECLARE
    l_result                     BOOLEAN := FALSE; -- Флаг успешного удаления записи
    l_processed_rows             INT := 0;         -- Число строк обработанных командой удаления записи
    l_does_related_search_exist  INT := 0;         -- Флаг проверки существования исследования, связанного с мишенью
BEGIN
    -- Проверка наличия исследования, связанного с мишенью
    SELECT COUNT(*) INTO l_does_related_search_exist FROM registry.search WHERE target_id = p_id;

    -- Удаление данных о мишени, если с ней нет связанных данных
    IF l_does_related_search_exist = 0 THEN
        -- Удаление данных о мишени
            -- Удаление строк из таблицы registry.target_file
            DELETE FROM registry.target_file WHERE target_id = p_id;
    
            -- Удаление строки из таблицы registry.target
            DELETE FROM registry.target WHERE id = p_id;
    
            -- Считывание результата удаления
            GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
            l_result := l_processed_rows > 0;
    ELSE
        -- Убираем флаг успешного удаления данных о мишени
        l_result := FALSE;
    END IF;

RETURN l_result;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_target_file_add(p_target_id INT, p_type CHARACTER VARYING, p_file_path CHARACTER VARYING, p_file_name CHARACTER VARYING)
    RETURNS BOOLEAN
    LANGUAGE PLPGSQL
AS
$$
-- Добавление записи о файле в таблицу registry.target_file
-- Входные параметры:
-- p_target_id           - Идентификатор мишени
-- p_type                - Вид файла
-- p_file_path           - Полный путь к файлу
-- p_file_name           - Имя файла
-- Выходные параметры:
-- l_result              - Флаг добавления новой записи в таблицу registry.target_file
DECLARE
    l_result                 BOOLEAN := FALSE; -- Флаг успешного добавления файла мишени
    l_processed_rows         INT := 0;         -- Число строк обработанных командой вставки записи о новом файле мишени
    l_does_target_file_exist INT := 0;         -- Флаг проверки существования файла для такой мишени и с таким же именем
BEGIN
    -- Проверка наличия файла с таким же полным именем или с таким же типом у этой же мишени
    SELECT COUNT(*) INTO l_does_target_file_exist FROM registry.target_file WHERE file_path = p_file_path OR (target_id = p_target_id AND type = p_type);

    -- Занесение записи о файле в таблицу, если такого файла ещё нет
    IF l_does_target_file_exist = 0 AND p_file_path IS NOT NULL AND p_file_name IS NOT NULL AND LENGTH(p_file_path) > 0 AND LENGTH(p_file_name) > 0 THEN
        -- Добавление файла
            -- Вставка записи в таблицу
            INSERT INTO registry.target_file(id, target_id, type, file_path, file_name)
            VALUES(NEXTVAL('registry.seq_target_file_id'), p_target_id, p_type, p_file_path, p_file_name);
            -- Считывание результата добавления
            GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
            l_result := l_processed_rows > 0;
    ELSE
        -- Убираем флаг успешного добавления записи о файле
        l_result := FALSE;
    END IF;

    RETURN l_result;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_target_file_delete(p_id INT)
    RETURNS BOOLEAN
    LANGUAGE PLPGSQL
AS
$$
-- Удаление записи о файле из таблицы registry.target_file
-- Входные параметры:
-- p_id                  - Идентификатор файла
-- Выходные параметры:
-- l_result              - Флаг удаление записи из таблицы registry.target_file
DECLARE
    l_result                  BOOLEAN := FALSE; -- Флаг успешного удаления записи
    l_processed_rows          INT := 0;         -- Число строк обработанных командой удаления записи
BEGIN
    -- Удаление записи
    DELETE FROM registry.target_file WHERE id = p_id;

    -- Считывание результата удаления
    GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
    l_result := l_processed_rows > 0;

    RETURN l_result;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_get_target_file(p_target_id INTEGER, p_docker_name CHARACTER VARYING)
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Найти подходящий файл мишени для заданного приложения докинга
-- Входные параметры:
-- p_target_id         - Идентификатор мишени
-- p_docker_name       - Имя приложения для докинга
-- Выходные параметры:
DECLARE
    l_id   INT := 0;      -- Идентификатор нужного файла из таблицы registry.target_file 
    p_type VARCHAR(16);   -- Тип нужного файла из таблицы registry.target_file 
BEGIN
	IF p_docker_name = 'cmdock' THEN 
		p_type := 'mol2'; 
	END IF;
        IF p_docker_name = 'autodockvina' THEN 
		p_type := 'pdbqt'; 
	END IF;
	SELECT id INTO l_id FROM registry.target_file WHERE target_id = p_target_id AND type = p_type;	
	RETURN l_id;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_reference_ligand_add(p_target_id INT, p_name CHARACTER VARYING, 
                                                                 p_x NUMERIC, p_y NUMERIC, p_z NUMERIC, p_chain CHARACTER VARYING)
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление записи о справочном лиганде в таблицу registry.reference_ligand
-- Входные параметры:
-- p_target_id           - Идентификатор мишени
-- p_name                - Имя лиганда
-- p_x           
-- p_y           
-- p_z
-- p_chain
-- Выходные параметры:
-- l_id                  - Идентификатор добавленного лиганда 
DECLARE    
    l_result            BOOLEAN := FALSE; -- Флаг успешного добавления справочного лиганда
    l_id                INT := -1;        -- Идентификатор нового лиганда
    l_processed_rows    INT := 0;         -- Число строк обработанных командой вставки записи о новом справочном лиганде
    l_does_reflig_exist INT := 0;         -- Флаг проверки существования справочного лиганда для такой мишени, с таким же именем и цепью
BEGIN
    -- Проверка наличия файла с таким же полным именем или с таким же типом у этой же мишени
    SELECT COUNT(*) INTO l_does_reflig_exist FROM registry.reference_ligand WHERE (target_id = p_target_id AND name = p_name AND chain = p_chain);
    -- Занесение записи о файле в таблицу, если такого файла ещё нет
    IF l_does_reflig_exist = 0 THEN
        -- Добавление справочного лиганда
			SELECT NEXTVAL('registry.seq_reference_ligand_id') INTO l_id;
            -- Вставка записи в таблицу
            INSERT INTO registry.reference_ligand(id, target_id, name, center_x, center_y, center_z, chain)
            VALUES(l_id, p_target_id, p_name, p_x, p_y, p_z, p_chain);
            GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
            l_result := l_processed_rows > 0;
    ELSE
        -- Убираем флаг успешного добавления записи о справочном лиганде
        l_result := FALSE;
    END IF;

    IF NOT l_result THEN
        l_id := -1;
    END IF;

    RETURN l_id;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_library_add(p_name CHARACTER VARYING, p_system_name CHARACTER VARYING, p_description CHARACTER VARYING, p_authors CHARACTER VARYING, p_source CHARACTER VARYING, p_usage_type CHAR(1), p_state CHAR(1))
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление библиотеки лигандов в таблицу registry.library
-- Входные параметры:
-- p_name                - Название библиотеки лигандов
-- p_system_name         - Системное имя библиотеки лигандов
-- p_description         - Описание библиотеки лигандов
-- p_authors             - Авторы библиотеки лигандов
-- p_source              - Источник библиотеки лигандов
-- p_usage_type          - Вид использования ('O' - open, 'R' - restricted, 'P' - private)
-- p_state               - Состояние ('P' - preparing, 'U' - unlocked, 'L' - locked, 'A' - archived)
-- Выходные параметры:
-- l_result              - Флаг добавления новой записи в таблицу registry.library
--
DECLARE
    l_result             BOOLEAN := FALSE; -- Флаг успешного добавления библиотеки лигандов
    l_id                 INT := -1;        -- Идентификатор новой библиотеки лигандов
    l_processed_rows     INT := 0;         -- Число строк, обработанных командой вставки записи о новой библиотеки лигандов
    l_does_library_exist INT := 0;         -- Флаг проверки существования библиотеки лигандов с таким же именем
BEGIN
    -- Проверка наличия библиотеки лигандов с таким же именем
    SELECT COUNT(*) INTO l_does_library_exist FROM registry.library WHERE name = p_name OR system_name = p_system_name;

    -- Занесение библиотеки лигандов в таблицу, если библиотеки лигандов с таким же именем ещё нет
    IF l_does_library_exist = 0 AND p_name IS NOT NULL AND LENGTH(p_name) > 0 AND p_system_name IS NOT NULL AND LENGTH(p_system_name) > 0 THEN
        -- Добавление библиотеки лигандов
            SELECT NEXTVAL('registry.seq_library_id') INTO l_id;
            -- Вставка записи в таблицу
            INSERT INTO registry.library(id, create_time, name, system_name, description, authors, source, usage_type, state)
            VALUES(l_id, CURRENT_TIMESTAMP, p_name, p_system_name, p_description, p_authors, p_source, p_usage_type, p_state);
            -- Считывание результата добавления
            GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
            l_result := l_processed_rows > 0;
    ELSE
        -- Убираем флаг успешного добавления мишени
        l_result := FALSE;
    END IF;

    IF NOT l_result THEN
        l_id := -1;
    END IF;

    RETURN l_id;
END;
$$;
-- Функция создания протокола докинга для AutoDock Vina
CREATE OR REPLACE FUNCTION registry.docker_autodockvina_protocol_add(p_name CHARACTER VARYING, p_system_name CHARACTER VARYING, 
								     p_description CHARACTER VARYING, 
								     p_template_in_path CHARACTER VARYING, p_template_in_name CHARACTER VARYING,
                                                                     p_template_out_path CHARACTER VARYING, p_template_out_name CHARACTER VARYING,
                                                                     p_config_path CHARACTER VARYING, p_config_name CHARACTER VARYING)
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление записи о протоколе докинга в таблицу registry.docker_protocol
-- Входные параметры:
-- p_name              - 
-- p_system_name       - 
-- p_template_in_path  -
-- p_template_in_name  -
-- p_template_out_path -
-- p_template_out_name -
-- p_config_path       -
-- p_config_name       -
-- Выходные параметры:
-- l_id - Идентификатор добавленного протокола докинга
DECLARE
    l_result BOOLEAN := FALSE;   -- Флаг успешного добавления протокола докинга
    l_template_in_id INT := -1;  -- Идентификатор файла BOINC-шаблона In
    l_template_out_id INT := -1; -- Идентификатор файла BOINC-шаблона Out
    l_config_id INT := -1;       -- Идентификатор файла параметров протокола докинга
    l_id INT := -1;              -- Идентификатор нового протокола докинга
    l_processed_rows INT := 0;   -- Число строк обработанных командой вставки записи о новом протоколе докинга
BEGIN
    SELECT NEXTVAL('registry.seq_docker_protocol_id') INTO l_id;
    SELECT NEXTVAL('registry.seq_docker_protocol_item_id') INTO l_template_in_id;
    SELECT NEXTVAL('registry.seq_docker_protocol_item_id') INTO l_template_out_id;  
    SELECT NEXTVAL('registry.seq_docker_protocol_item_id') INTO l_config_id;    

    -- Добавление протокола докинга
    -- Вставка записи в таблицу
    INSERT INTO registry.docker_protocol(id, name, system_name, description)
    VALUES(l_id, p_name, p_system_name, p_description);

    -- Считывание результата добавления
    GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
       l_result := l_processed_rows > 0;

    IF NOT l_result THEN
        l_id := -1;
    	RETURN l_id;
    END IF;

    -- Добавление файлов протокола докинга
    -- Вставка записей о трех необходимых файлах в таблицу
    INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, "type", order_number, file_path, file_name)
    VALUES(l_template_in_id, l_id, 'autodockvina', 'TemplateIn', 0, p_template_in_path, p_template_in_name),
          (l_template_out_id, l_id, 'autodockvina', 'TemplateOut', 1, p_template_out_path, p_template_out_name),
          (l_config_id, l_id, 'autodockvina', 'AutoDockVinaConfigTXT', 2, p_config_path, p_config_name);

    -- Считывание результата добавления
    GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
       l_result := l_processed_rows > 0;

    IF NOT l_result THEN
        l_id := -1;
    	RETURN l_id;
    END IF;

    RETURN l_id;
END;
$$;
-- Функция создания протокола докинга для CmDock
CREATE OR REPLACE FUNCTION registry.docker_cmdock_protocol_add(p_name CHARACTER VARYING, p_system_name CHARACTER VARYING, p_description CHARACTER VARYING,
                                                               p_template_in_path CHARACTER VARYING, p_template_in_name CHARACTER VARYING,
                                                               p_template_out_path CHARACTER VARYING, p_template_out_name CHARACTER VARYING,
                                                               p_prm_path CHARACTER VARYING, p_prm_name CHARACTER VARYING, 
                                                               p_as_path CHARACTER VARYING, p_as_name CHARACTER VARYING, 
                                                               p_ptc_path CHARACTER VARYING, p_ptc_name CHARACTER VARYING)
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление записи о протоколе докинга в таблицу registry.docker_protocol
-- Входные параметры:
-- p_name              - 
-- p_system_name       - 
-- p_template_in_path  -
-- p_template_in_name  -
-- p_template_out_path -
-- p_template_out_name -
-- p_prm_path          -
-- p_prm_name          -
-- p_as_path           -
-- p_as_name           -
-- p_ptc_path          -
-- p_ptc_name          -
-- Выходные параметры:
-- l_id - Идентификатор добавленного протокола докинга
DECLARE
    l_result BOOLEAN := FALSE;   -- Флаг успешного добавления протокола докинга
    l_template_in_id INT := -1;  -- Идентификатор файла BOINC-шаблона In
    l_template_out_id INT := -1; -- Идентификатор файла BOINC-шаблона Out
    l_prm_id INT := -1;          -- Идентификатор prm-файла 
    l_as_id INT := -1;           -- Идентификатор as-файла 
    l_ptc_id INT := -1;          -- Идентификатор ptc-файла 
    l_id INT := -1;              -- Идентификатор нового протокола докинга
    l_processed_rows INT := 0;   -- Число строк обработанных командой вставки записи о новом протоколе докинга
BEGIN
    SELECT NEXTVAL('registry.seq_docker_protocol_id') INTO l_id;
    SELECT NEXTVAL('registry.seq_docker_protocol_item_id') INTO l_template_in_id;
    SELECT NEXTVAL('registry.seq_docker_protocol_item_id') INTO l_template_out_id;
    SELECT NEXTVAL('registry.seq_docker_protocol_item_id') INTO l_prm_id;
    SELECT NEXTVAL('registry.seq_docker_protocol_item_id') INTO l_as_id;
    SELECT NEXTVAL('registry.seq_docker_protocol_item_id') INTO l_ptc_id;

    -- Добавление протокола докинга
    -- Вставка записи в таблицу
    INSERT INTO registry.docker_protocol(id, name, system_name, description)
    VALUES(l_id, p_name, p_system_name, p_description);

    -- Считывание результата добавления
    GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
       l_result := l_processed_rows > 0;

    IF NOT l_result THEN
        l_id := -1;
        RETURN l_id;
    END IF;

    -- Добавление файлов протокола докинга
    -- Вставка записей о 5 необходимых файлах в таблицу
    INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, "type", order_number, file_path, file_name)
    VALUES(l_template_in_id, l_id, 'cmdock', 'TemplateIn', 0, p_template_in_path, p_template_in_name),
          (l_template_out_id, l_id, 'cmdock', 'TemplateOut', 1, p_template_out_path, p_template_out_name),
          (l_prm_id, l_id, 'cmdock', 'CmDockConfigPRM', 2, p_prm_path, p_prm_name),
          (l_as_id, l_id, 'cmdock', 'CmDockConfigAS', 3, p_as_path, p_as_name),
          (l_ptc_id, l_id, 'cmdock', 'CmDockConfigPTC', 4, p_ptc_path, p_ptc_name);

    -- Считывание результата добавления
    GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
       l_result := l_processed_rows > 0;

    IF NOT l_result THEN
        l_id := -1;
        RETURN l_id;
    END IF;

    RETURN l_id;
END;
$$;
-- Функция создания протокола поиска
CREATE OR REPLACE FUNCTION registry.hitvisc_search_protocol_add(p_hit_criterion CHAR(1), p_hit_threshold_energy NUMERIC, p_hit_threshold_efficiency NUMERIC,
                                                                p_stop_criterion CHAR(1), p_stop_fraction_ligands NUMERIC, p_stop_count_hits INTEGER,
                                                                p_stop_fraction_hits NUMERIC, p_is_notify_hits BOOL, p_is_notify_fraction_ligands BOOL,
                                                                p_value_notify_fraction_ligands NUMERIC)
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление записи о протоколе поиска в таблицу registry.search_protocol
-- Входные параметры:
-- p_hit_criterion                 - Критерий отбора хитов
-- p_hit_threshold_energy          - Пороговое значение энергии связывания
-- p_hit_threshold_efficiency      - Пороговое значение эффективности лиганда
-- p_stop_criterion                - Критерий остановки
-- p_stop_fraction_ligands         - Доля проверенных лигандов
-- p_stop_count_hits               - Число найденных хитов
-- p_stop_fraction_hits            - Доля хитов от числа лигандов
-- p_is_notify_hits                - Флаг оповещения о найденных хитах
-- p_is_notify_fraction_ligands    - Флаг оповещения об обработке заданной доли лигандов
-- p_value_notify_fraction_ligands - Значение доли обработанных лигандов
-- Выходные параметры:
-- l_id - Идентификатор добавленного протокола поиска
DECLARE
    l_result BOOLEAN := FALSE; -- Флаг успешного добавления протокола поиска
    l_id INT := -1;            -- Идентификатор нового протокола поиска
    l_processed_rows INT := 0; -- Число строк обработанных командой вставки записи о новом протоколе поиска
    v_threshold_column TEXT;   -- Заголовок столбца с критерием отбора хитов
    v_threshold_value TEXT;    -- Пороговое значение для отбора хитов
    v_stop_column TEXT;        -- Заголовок столбца с критерием остановки
    v_stop_value TEXT;         -- Пороговое значение для остановки
BEGIN
    -- Добавление протокола поиска
    SELECT NEXTVAL('registry.seq_search_protocol_id') INTO l_id;

    -- Формирование команды добавления протокола поиска в зависимости от переданных параметров
    CASE
        WHEN p_hit_criterion = 'N' THEN v_threshold_column := 'hit_threshold_energy'; v_threshold_value := p_hit_threshold_energy;
        WHEN p_hit_criterion = 'F' THEN v_threshold_column := 'hit_threshold_efficiency'; v_threshold_value := p_hit_threshold_efficiency;
        ELSE
        --  do nothing      
    END CASE;

    CASE
        WHEN p_stop_criterion = 'L' THEN v_stop_column := 'stop_fraction_ligands'; v_stop_value := p_stop_fraction_ligands;
        WHEN p_stop_criterion = 'H' THEN v_stop_column := 'stop_count_hits'; v_stop_value := p_stop_count_hits;
        WHEN p_stop_criterion = 'F' THEN v_stop_column := 'stop_fraction_hits'; v_stop_value := p_stop_fraction_hits;
        ELSE
        --  do nothing
    END CASE;

    EXECUTE FORMAT('INSERT INTO registry.search_protocol(id, hit_criterion, %I, stop_criterion, %I, is_notify_hits, 
                    is_notify_fraction_ligands, value_notify_fraction_ligands) VALUES(%L, %L, %L, %L, %L, %L, %L, %L)',
                    v_threshold_column, v_stop_column, l_id, p_hit_criterion, v_threshold_value, p_stop_criterion, v_stop_value,
                    p_is_notify_hits, p_is_notify_fraction_ligands, p_value_notify_fraction_ligands);

    -- Считывание результата добавления
    GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
       l_result := l_processed_rows > 0;

    IF NOT l_result THEN
        l_id := -1;
    END IF;

    RETURN l_id;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitivsc_user_add(p_login VARCHAR(64), p_email VARCHAR(64), p_password VARCHAR(64), p_name VARCHAR(64), p_description VARCHAR(256), p_boinc_user_id INT, p_boinc_authenticator VARCHAR(32), p_boinc_password VARCHAR(32))
    RETURNS BOOLEAN
    LANGUAGE PLPGSQL
AS
$$
-- Добавление пользователя в таблицу registry.user
-- Входные параметры:
-- p_login               - Логин пользователя (по факту - e-mail)
-- p_email               - E-mail пользователя
-- p_password            - Пароль (при вставке в таблицу он шифруется функцией MD5
-- p_name                - Отображаемое имя
-- p_description         - Описание пользователя
-- p_boinc_user_id       - Идентификатор соответствующего пользователя в BOINC-сервере
-- p_boinc_authenticator - Ключ в BOINC-сервере (authenticator)
-- p_boinc_password      - Пароль в BOINC-сервере в незашифрованном виде
-- Выходные параметры:
-- l_result              - Флаг добавления новой записи в таблицу registry.user
--
-- Перед добавлением записи логин (он же e-mail) приводится к стандартному виду - нижний регистр, убираются пробелы с конца и начала
--
DECLARE
    l_result           BOOLEAN := FALSE; -- Флаг успешного добавления пользователя
    l_processed_rows   INT := 0;         -- Число строк обработанных командой вставки записи о новом пользователе
    l_reduced_login    VARCHAR(64);      -- Логин, приведённый к стандартной форме - нижний регистр и удалённые пробелы с концов строки
    l_reduced_email    VARCHAR(64);      -- E-mail, приведённый к стандартной форме - нижний регистр и удалённые пробелы с концов строки
    l_does_user_exist  INT := 0;         -- Флаг проверки существования пользователя с таким же логином
    l_does_email_exist INT := 0;         -- Флаг проверки существования пользователя с таким же e-mail
BEGIN
    -- Приведение логина к стандартной форме
    l_reduced_login := LOWER(TRIM(BOTH p_login));

    -- Приведение e-mail к стандартной форме
    l_reduced_email := LOWER(TRIM(BOTH p_email));

    -- Проверка наличия пользователя с таким же логином
    SELECT COUNT(*) INTO l_does_user_exist FROM registry."user" WHERE login = l_reduced_login;

    -- Проверка наличия пользователя с таким же логином
    SELECT COUNT(*) INTO l_does_email_exist FROM registry."user" WHERE email = l_reduced_email;

    -- Занесение пользователя в таблицу, если такого логина ещё нет
    IF l_does_user_exist = 0 AND l_does_email_exist = 0 AND LENGTH(l_reduced_login) IS NOT NULL AND LENGTH(l_reduced_login) > 0 AND LENGTH(l_reduced_email) IS NOT NULL AND LENGTH(l_reduced_email) > 0  THEN
        -- Добавление пользователя
            -- Вставка записи в таблицу
            INSERT INTO registry."user"(id, create_time, login, email, password_hash, name, description, state, boinc_user_id, boinc_authenticator, boinc_password)
            VALUES(NEXTVAL('registry.seq_user_id'), CURRENT_TIMESTAMP, l_reduced_login, l_reduced_email, MD5(p_password), p_name, p_description, 'U', p_boinc_user_id, p_boinc_authenticator, p_boinc_password);
            -- Считывание результата добавления
            GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
            l_result := l_processed_rows > 0;
    ELSE
        -- Убираем флаг успешного добавления пользователя
        l_result := FALSE;
    END IF;

    RETURN l_result;
END;
$$;
-- Функция создания поиска
CREATE OR REPLACE FUNCTION registry.hitvisc_search_add(p_name CHARACTER VARYING, p_system_name CHARACTER VARYING, p_description CHARACTER VARYING, 
	p_usage_type CHAR(1), p_target_id INT, p_library_id INT, p_docker_id INT, p_docker_protocol_id INT, p_search_protocol_id INT, 
	p_host_usage_type CHAR(1), p_prefix CHARACTER VARYING, p_state CHAR(1))
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление поиска в таблицу registry.search
-- Входные параметры:
-- p_name                - Название поиска
-- p_system_name         - Системное имя поиска
-- p_description         - Описание поиска
-- p_usage_type          - Вид использования ('O' - open, 'R' - restricted, 'P' - private)
-- p_target_id           - Идентификатор мишени
-- p_library_id          - Идентификатор библиотеки лигандов
-- p_docker_id           - Идентификатор приложения докинга
-- p_docker_protocol_id  - Идентификатор протокола докинга
-- p_search_protocol_id  - Идентификатор протокола поиска
-- p_host_usage_type     - Тип вычислительных ресурсов ('T' - test, 'R' - private, 'P' - public) 
-- p_prefix              - Префикс для именования заданий и вспомогательных объектов
-- p_state               - Состояние ('P' - preparing, 'U' - unlocked, 'L' - locked, 'A' - archived)
-- Выходные параметры:
-- l_result              - Флаг добавления новой записи в таблицу registry.search
-- l_id                  - Идентификатор нового поиска
--
DECLARE
    l_result            BOOLEAN := FALSE; -- Флаг успешного добавления поиска
    l_id                INT := -1;        -- Идентификатор нового поиска
    l_processed_rows    INT := 0;         -- Число строк, обработанных командой вставки записи о новом поиска
    l_does_search_exist INT := 0;         -- Флаг проверки существования поиска с таким же именем
BEGIN
    -- Проверка наличия поиска с таким же именем
    SELECT COUNT(*) INTO l_does_search_exist FROM registry.search WHERE name = p_name OR system_name = p_system_name;

    -- Занесение поиска в таблицу, если поиска с таким же именем ещё нет
    IF l_does_search_exist = 0 AND p_name IS NOT NULL AND LENGTH(p_name) > 0 AND p_system_name IS NOT NULL AND LENGTH(p_system_name) > 0 THEN
        -- Добавление поиска
            SELECT NEXTVAL('registry.seq_search_id') INTO l_id;
            -- Вставка записи в таблицу
            INSERT INTO registry.search(id, create_time, name, system_name, description, usage_type, target_id, library_id, docker_id, docker_protocol_id, search_protocol_id, host_usage_type, prefix, state)
            VALUES(l_id, CURRENT_TIMESTAMP, p_name, p_system_name, p_description, p_usage_type, p_target_id, p_library_id, p_docker_id, p_docker_protocol_id, p_search_protocol_id, p_host_usage_type, p_prefix, p_state);
            -- Считывание результата добавления
            GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
            l_result := l_processed_rows > 0;
    ELSE
        -- Убираем флаг успешного добавления поиска
        l_result := FALSE;
    END IF;

    IF NOT l_result THEN 
        l_id := -1; 
    END IF;

    RETURN l_id; 
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_ligand_add_multiple(p_filename TEXT, p_library_id INT)
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление множества лигандов в таблицу registry.ligand из указанного файла
-- Входные параметры:
-- p_filename          - Имя файла со свойствами лигандов
-- p_library_id        - Идентификатор библиотеки лигандов
-- Выходные параметры:
-- l_processed_rows    - Число строк, обработанных командой вставки записи о новых лигандах
--
DECLARE
    l_result             BOOLEAN := FALSE; -- Флаг успешного добавления лигандов
    l_processed_rows     INT := 0;         -- Число строк, обработанных командой вставки записи о новых лигандах
    l_does_library_exist INT := 0;         -- Флаг проверки существования библиотеки
BEGIN
    -- Проверка наличия библиотеки с указанным идентификатором
    SELECT COUNT(*) INTO l_does_library_exist FROM registry.library WHERE (id = p_library_id); 

     -- Занесение лиганда в таблицу, если лиганда с таким же именем в этой библиотеке ещё нет
    IF l_does_library_exist = 1 THEN
        -- Добавление лигандов
        DROP TABLE IF EXISTS registry.ligand_tmp;
        CREATE TABLE registry.ligand_tmp(name VARCHAR(256) NOT NULL, ligand_formula VARCHAR(256), 
                                         ligand_mol_weight NUMERIC, ligand_exact_mass NUMERIC, 
                                         ligand_canonical_smiles VARCHAR(256), ligand_inchi VARCHAR(128),
                                         ligand_num_atoms SMALLINT, ligand_num_bonds SMALLINT, 
                                         ligand_num_residues SMALLINT, ligand_sequence VARCHAR(256), 
                                         ligand_num_rings SMALLINT, ligand_logp NUMERIC, 
                                         ligand_psa NUMERIC, ligand_mr NUMERIC);
        EXECUTE FORMAT('COPY registry.ligand_tmp (name, ligand_formula, ligand_mol_weight, ligand_exact_mass, 
                        ligand_canonical_smiles, ligand_inchi, ligand_num_atoms, ligand_num_bonds, 
                        ligand_num_residues, ligand_sequence, ligand_num_rings, ligand_logp, ligand_psa, ligand_mr)
                        FROM %L WITH (DELIMITER '' '');', p_filename);
        INSERT INTO registry.ligand (id, library_id, name, ligand_formula, ligand_mol_weight, ligand_exact_mass, 
                                     ligand_canonical_smiles, ligand_inchi, ligand_num_atoms, ligand_num_bonds, 
                                     ligand_num_residues, ligand_sequence, ligand_num_rings, ligand_logp, 
                                     ligand_psa, ligand_mr)
        SELECT NEXTVAL('registry.seq_ligand_id'), p_library_id, name, ligand_formula, ligand_mol_weight, 
               ligand_exact_mass, ligand_canonical_smiles, ligand_inchi, ligand_num_atoms, ligand_num_bonds, 
               ligand_num_residues, ligand_sequence, ligand_num_rings, ligand_logp, ligand_psa, ligand_mr 
               FROM registry.ligand_tmp ON CONFLICT DO NOTHING;   
        -- Считывание результата добавления
        GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
        l_result := l_processed_rows > 0;
        DROP TABLE registry.ligand_tmp;
    ELSE
        -- Убираем флаг успешного добавления лигандов
        l_result := FALSE;
    END IF;

    IF NOT l_result THEN
        l_processed_rows := -1;
    END IF;

    RETURN l_processed_rows;
END;
$$;
CREATE OR REPLACE FUNCTION registry.hitvisc_entity_mapping_add(p_front_entity_id INT, p_back_entity_id INT, p_entity_type CHAR(1))
    RETURNS INTEGER
    LANGUAGE PLPGSQL
AS
$$
-- Добавление записи в таблицу registry.entity_mapping 
-- Входные параметры:
-- p_front_entity_id - Идентификатор фронтенд-сущности
-- p_back_entity_id  - Идентификатор бэкенд-сущности
-- p_entity_type     - Тип сущности (T - мишень; L - библиотека лигандов; S - поиск)
DECLARE
    l_result             BOOLEAN := FALSE; -- Флаг успешного добавления записи
    l_id                 INT := -1;        -- Идентификатор новой записи
    l_processed_rows     INT := 0;         -- Число строк, обработанных командой вставки записи
    l_does_mapping_exist INT := 0;         -- Флаг проверки существования записи с такой же парой значений 
                                           -- (id фронт-сущности, тип) или (id бэк-сущности, тип)   
BEGIN
    -- Проверка наличия записи с такой же парой значений (id фронт-сущности, тип) или (id бэк-сущности, тип)
    SELECT COUNT(*) INTO l_does_mapping_exist FROM registry.entity_mapping 
        WHERE (front_entity_id = p_front_entity_id AND entity_type = p_entity_type) 
           OR (back_entity_id = p_back_entity_id AND entity_type = p_entity_type);

    -- Занесение записи в таблицу, если записи с такой же парой значений ещё нет
    IF l_does_mapping_exist = 0 AND p_front_entity_id IS NOT NULL AND p_back_entity_id IS NOT NULL THEN
        -- Добавление записи
            SELECT NEXTVAL('registry.seq_entity_mapping_id') INTO l_id;
            -- Вставка записи в таблицу
            INSERT INTO registry.entity_mapping(id, front_entity_id, back_entity_id, entity_type)
            VALUES(l_id, p_front_entity_id, p_back_entity_id, p_entity_type);
            -- Считывание результата добавления
            GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
            l_result := l_processed_rows > 0;
    ELSE
        -- Убираем флаг успешного добавления поиска
        l_result := FALSE;
    END IF;

    IF NOT l_result THEN
        l_id := -1;
    END IF;

    RETURN l_id;
END;
$$;
-- Функция обновления статистических показателей компьютера
CREATE OR REPLACE FUNCTION registry.boinc_host_update_stat(p_boinc_host_id INTEGER, p_last_request_time TIMESTAMP, p_tasks_completed INTEGER, p_tasks_in_progress INTEGER)
    RETURNS BOOLEAN
    LANGUAGE PLPGSQL
AS
$$
-- Обновление статистических показателей компьютера
-- Входные параметры:
-- p_boinc_host_id     - Идентификатор компьютера в BOINC-проекте
-- p_last_request_time - Время последнего образения компьютера к серверу
-- p_tasks_completed   - Число заданий, выполненных со времени последнего обновления
-- p_tasks_in_progress - Число заданий, находящихся сейчас в обработке
-- Выходные параметры:
-- l_result            - Флаг успешного обновления данных 
--
-- Запросом вида INSERT<-SELECT проверяется, что компьютер не был ранее добавлен
--
DECLARE
    l_result         BOOLEAN := FALSE; -- Флаг успешного обновления данных 
    l_processed_rows INT := 0;         -- Число строк обработанных командой обновления данных
BEGIN
    -- Обновление стетистических показателей компьютера
    UPDATE registry.host
       SET tasks_progress = p_tasks_in_progress,
           tasks_completed = tasks_completed + p_tasks_completed,
           last_request_time = p_last_request_time
     WHERE boinc_host_id = p_boinc_host_id;
 
    -- Считывание результата добавления
    GET DIAGNOSTICS l_processed_rows := ROW_COUNT;
    l_result := l_processed_rows > 0;

    RETURN l_result;
END;
$$;
