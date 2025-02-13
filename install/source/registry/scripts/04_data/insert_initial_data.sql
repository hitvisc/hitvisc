--------------------------------------------------------------------------------
-- Заполнение справочников
--------------------------------------------------------------------------------
-- Наполняем справочник состояний задач
INSERT INTO registry.workunit_state(id, name, description) VALUES(1, 'GENERATED', 'Создана');
INSERT INTO registry.workunit_state(id, name, description) VALUES(2, 'IN_PROCESS', 'В работе');
INSERT INTO registry.workunit_state(id, name, description) VALUES(3, 'COMPUTED', 'Вычислена');
INSERT INTO registry.workunit_state(id, name, description) VALUES(4, 'ERROR', 'Ошибка');
INSERT INTO registry.workunit_state(id, name, description) VALUES(5, 'FINISHED', 'Завершена');
INSERT INTO registry.workunit_state(id, name, description) VALUES(6, 'NOT_NEEDED', 'Не нужна');
-- SELECT * FROM registry.workunit_state;

-- Наполняем справочник привилегий
INSERT INTO registry.privilege(id, name, type, description) VALUES(1, 'MASTER', 'S', 'Владелец системы');
INSERT INTO registry.privilege(id, name, type, description) VALUES(2, 'LOGIN', 'S', 'Вход в систему');
INSERT INTO registry.privilege(id, name, type, description) VALUES(3, 'CREATE USER', 'S', 'Создание пользователя');
INSERT INTO registry.privilege(id, name, type, description) VALUES(4, 'LOCK USER', 'S', 'Блокирование пользователя');
INSERT INTO registry.privilege(id, name, type, description) VALUES(5, 'CREATE TARGET', 'S', 'Создание мишени');
INSERT INTO registry.privilege(id, name, type, description) VALUES(6, 'VIEW TARGET', 'O', 'Просмотр мишени');
INSERT INTO registry.privilege(id, name, type, description) VALUES(7, 'USE TARGET', 'O', 'Использование мишени');
INSERT INTO registry.privilege(id, name, type, description) VALUES(8, 'CREATE LIBRARY', 'S', 'Создание библиотеки');
INSERT INTO registry.privilege(id, name, type, description) VALUES(9, 'VIEW LIBRARY', 'O', 'Просмотр библиотеки');
INSERT INTO registry.privilege(id, name, type, description) VALUES(10, 'USE LIBRARY', 'O', 'Использование библиотеки');
INSERT INTO registry.privilege(id, name, type, description) VALUES(11, 'LIBRARY OWNER', 'O', 'Владение библиотекой');
INSERT INTO registry.privilege(id, name, type, description) VALUES(12, 'CREATE SEARCH', 'S', 'Создание поиска');
INSERT INTO registry.privilege(id, name, type, description) VALUES(13, 'VIEW SEARCH', 'O', 'Просмотр поиска');
INSERT INTO registry.privilege(id, name, type, description) VALUES(14, 'USE SEARCH', 'O', 'Использование поиска');
INSERT INTO registry.privilege(id, name, type, description) VALUES(15, 'SEARCH OWNER', 'O', 'Владение поиска');
INSERT INTO registry.privilege(id, name, type, description) VALUES(16, 'USE RESOURCE', 'O', 'Использование вычислительного ресурса');
--------------------------------------------------------------------------------

-- Добавление учетной записи администратора системы HiTViSc
INSERT INTO registry.user(id, create_time, login, email, password_hash, name, description, state, boinc_user_id, boinc_authenticator, boinc_password) VALUES(NEXTVAL('registry.seq_user_id'), CURRENT_TIMESTAMP, 'adm.hitvisc@yandex.ru', 'adm.hitvisc@yandex.ru', MD5('password'), 'Administrator', 'Administrator of HiTViSc system', 'U', 1, '589f3b592c15558d947a2b902c3b640e', 'regnode');
--------------------------------------------------------------------------------

-- Добавление программ молекулярного докинга
INSERT INTO registry.docker(id, name, system_name, description) VALUES(1, 'CmDock', 'cmdock', 'Curie Marie Dock');
INSERT INTO registry.docker_version(id, docker_id, version_number) VALUES(1, 1, 0.2);

INSERT INTO registry.docker(id, name, system_name, description) VALUES(2, 'AutoDock Vina', 'autodockvina', 'AutoDock Vina');
INSERT INTO registry.docker_version(id, docker_id, version_number) VALUES(2, 2, 1.25);
--------------------------------------------------------------------------------

