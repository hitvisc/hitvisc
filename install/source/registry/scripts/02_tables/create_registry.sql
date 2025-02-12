-- Создание схемы
CREATE SCHEMA registry;

-- Перечень мишеней
CREATE TABLE registry.target
(
	id	    INT NOT NULL,
	create_time TIMESTAMP NOT NULL,
	name        VARCHAR(256) NOT NULL,
	system_name VARCHAR(64) NOT NULL,
	description VARCHAR(1024) NOT NULL,
	authors     VARCHAR(256) NOT NULL,
	source      VARCHAR(256),
	usage_type  CHAR(1) NOT NULL,
	state       CHAR(1) NOT NULL
);

CREATE UNIQUE INDEX idx_target_pk ON registry.target(id);
CREATE UNIQUE INDEX idx_target_name_uq ON registry.target(name);
CREATE UNIQUE INDEX idx_target_system_name_uq ON registry.target(system_name);
ALTER TABLE registry.target ADD CONSTRAINT cs_target_pk PRIMARY KEY USING INDEX idx_target_pk;
ALTER TABLE registry.target ADD CONSTRAINT cs_target_name_uq UNIQUE(name);
ALTER TABLE registry.target ADD CONSTRAINT cs_target_system_name_uq UNIQUE(system_name);
ALTER TABLE registry.target ADD CONSTRAINT cs_target_usage_type_ck CHECK(usage_type IN('O', 'R', 'P'));
ALTER TABLE registry.target ADD CONSTRAINT cs_target_state_ck CHECK(state IN('P', 'U', 'L', 'A'));

COMMENT ON TABLE registry.target IS 'Мишень';
COMMENT ON COLUMN registry.target.id IS 'Идентификатор';
COMMENT ON COLUMN registry.target.create_time IS 'Время создания';
COMMENT ON COLUMN registry.target.name IS 'Название';
COMMENT ON COLUMN registry.target.system_name IS 'Внутреннее имя';
COMMENT ON COLUMN registry.target.description IS 'Описание';
COMMENT ON COLUMN registry.target.authors IS 'Авторы';
COMMENT ON COLUMN registry.target.source IS 'Источник';
COMMENT ON COLUMN registry.target.usage_type IS 'Вид использования: O - общая (open), R - закрытая (restricted), P - частная (private)';
COMMENT ON COLUMN registry.target.state IS 'Состояние мишени: P - создается (preparing); U - не заблокирована, можно изменять и удалять (unlocked); L - заблокирована - используется в поисках (locked); A - архивация, данные выносятся в архив (archived)';

-- Последовательность для нумерации мишеней
CREATE SEQUENCE registry.seq_target_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Файл мишени
CREATE TABLE registry.target_file
(
    id        INT NOT NULL,
    target_id INT NOT NULL,
    type      VARCHAR(16) NOT NULL,
    file_path VARCHAR(256) NOT NULL,
    file_name VARCHAR(256) NOT NULL
);

CREATE UNIQUE INDEX idx_target_file_pk ON registry.target_file(id);
CREATE INDEX idx_target_file_target_fk ON registry.target_file(target_id);
ALTER TABLE registry.target_file ADD CONSTRAINT cs_target_file_pk PRIMARY KEY USING INDEX idx_target_file_pk;
ALTER TABLE registry.target_file ADD CONSTRAINT cs_target_file_target_fk FOREIGN KEY(target_id) REFERENCES registry.target(id) ON DELETE CASCADE;

COMMENT ON TABLE registry.target_file IS 'Файл, входящий в описание мишени';
COMMENT ON COLUMN registry.target_file.id IS 'Идентификатор файла';
COMMENT ON COLUMN registry.target_file.target_id IS 'Идентификатор мишени';
COMMENT ON COLUMN registry.target_file.type IS 'Тип файла';
COMMENT ON COLUMN registry.target_file.file_path IS 'Путь к файлу';
COMMENT ON COLUMN registry.target_file.file_name IS 'Имя файла';

-- Последовательность для нумерации файлов мишени
CREATE SEQUENCE registry.seq_target_file_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень справочных лигандов
CREATE TABLE registry.reference_ligand
(
    id        INT NOT NULL,
    target_id INT NOT NULL,
    name      VARCHAR(64) NOT NULL,
    center_x  NUMERIC,
    center_y  NUMERIC,
    center_z  NUMERIC,
    chain     VARCHAR(2) NOT NULL
);

CREATE UNIQUE INDEX idx_reference_ligand_pk ON registry.reference_ligand(id);
CREATE INDEX idx_reference_ligand_target_fk ON registry.reference_ligand(target_id);
ALTER TABLE registry.reference_ligand ADD CONSTRAINT cs_reference_ligand_pk PRIMARY KEY USING INDEX idx_reference_ligand_pk;
ALTER TABLE registry.reference_ligand ADD CONSTRAINT cs_reference_ligand_target_fk FOREIGN KEY(target_id) REFERENCES registry.target(id) ON DELETE CASCADE;

COMMENT ON TABLE registry.reference_ligand IS 'Справочный лиганд';
COMMENT ON COLUMN registry.reference_ligand.id IS 'Идентификатор лиганда';
COMMENT ON COLUMN registry.reference_ligand.target_id IS 'Идентификатор мишени';
COMMENT ON COLUMN registry.reference_ligand.name IS 'Название лиганда';
COMMENT ON COLUMN registry.reference_ligand.center_x IS 'X-координата центра';
COMMENT ON COLUMN registry.reference_ligand.center_y IS 'Y-координата центра';
COMMENT ON COLUMN registry.reference_ligand.center_z IS 'Z-координата центра';
COMMENT ON COLUMN registry.reference_ligand.chain IS 'Идентификатор цепи';

-- Последовательность для нумерации справочных лигандов
CREATE SEQUENCE registry.seq_reference_ligand_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Файл справочного лиганда
CREATE TABLE registry.reference_ligand_file
(
    id                  INT NOT NULL,
    reference_ligand_id INT NOT NULL,
    type                VARCHAR(16) NOT NULL,
    file_path           VARCHAR(256) NOT NULL,
    file_name           VARCHAR(256) NOT NULL
);

CREATE UNIQUE INDEX idx_reference_ligand_file_pk ON registry.reference_ligand_file(id);
CREATE INDEX idx_reference_ligand_file_reference_ligand_fk ON registry.reference_ligand_file(reference_ligand_id);
ALTER TABLE registry.reference_ligand_file ADD CONSTRAINT cs_reference_ligand_file_pk PRIMARY KEY USING INDEX idx_reference_ligand_file_pk;
ALTER TABLE registry.reference_ligand_file ADD CONSTRAINT cs_reference_ligand_file_reference_ligand_fk FOREIGN KEY(reference_ligand_id) REFERENCES registry.reference_ligand(id) ON DELETE CASCADE;

COMMENT ON TABLE registry.reference_ligand_file IS 'Файл справочного лиганда';
COMMENT ON COLUMN registry.reference_ligand_file.id IS 'Идентификатор файла';
COMMENT ON COLUMN registry.reference_ligand_file.reference_ligand_id IS 'Идентификатор справочного лиганда';
COMMENT ON COLUMN registry.reference_ligand_file.file_path IS 'Путь к файлу';
COMMENT ON COLUMN registry.reference_ligand_file.file_name IS 'Имя файла';

-- Последовательность для нумерации файлов справочного лиганда
CREATE SEQUENCE registry.seq_reference_ligand_file_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень библиотек лигандов
CREATE TABLE registry.library
(
	id	    INT NOT NULL,
	create_time TIMESTAMP NOT NULL,
	name        VARCHAR(256) NOT NULL,
	system_name VARCHAR(64) NOT NULL,
	description VARCHAR(1024) NOT NULL,
	authors     VARCHAR(256) NOT NULL,
	source      VARCHAR(256),
	usage_type  CHAR(1) NOT NULL,
	state       CHAR(1) NOT NULL        
);

CREATE UNIQUE INDEX idx_library_pk ON registry.library(id);
CREATE UNIQUE INDEX idx_library_name_uq ON registry.library(name);
CREATE UNIQUE INDEX idx_library_system_name_uq ON registry.library(system_name);
ALTER TABLE registry.library ADD CONSTRAINT cs_library_pk PRIMARY KEY USING INDEX idx_library_pk;
ALTER TABLE registry.library ADD CONSTRAINT cs_library_name_uq UNIQUE(name);
ALTER TABLE registry.library ADD CONSTRAINT cs_library_system_name_uq UNIQUE(system_name);
ALTER TABLE registry.library ADD CONSTRAINT cs_library_usage_type_ck CHECK(usage_type IN('O', 'R', 'P'));
ALTER TABLE registry.library ADD CONSTRAINT cs_library_state_ck CHECK (state IN('P', 'U', 'L', 'A'));

COMMENT ON TABLE registry.library IS 'Библиотека с лигандами';
COMMENT ON COLUMN registry.library.id IS 'Идентификатор библиотеки';
COMMENT ON COLUMN registry.library.name IS 'Название библиотеки';
COMMENT ON COLUMN registry.library.system_name IS 'Внутреннее имя';
COMMENT ON COLUMN registry.library.description IS 'Описание';
COMMENT ON COLUMN registry.library.authors IS 'Авторы';
COMMENT ON COLUMN registry.library.source IS 'Источник';
COMMENT ON COLUMN registry.library.usage_type IS 'Вид использования: O - общая (open), R - закрытая (restricted), P - частная (private)';
COMMENT ON COLUMN registry.library.state IS 'Состояние библиотеки: P - создается (preparing); U - не заблокирована, можно изменять и удалять (unlocked); L - заблокирована - используется в поисках (locked); A - архивация, данные выносятся в архив (archived)';

-- Последовательность для нумерации библиотек лигандов
CREATE SEQUENCE registry.seq_library_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень модулей моделирования докинга
CREATE TABLE registry.docker
(
    id          INT NOT NULL,
    name        VARCHAR(64) NOT NULL,
    system_name VARCHAR(64) NOT NULL,
    description VARCHAR(1024)
);

CREATE UNIQUE INDEX idx_docker_pk ON registry.docker(id);
ALTER TABLE registry.docker ADD CONSTRAINT cs_docker_pk PRIMARY KEY USING INDEX idx_docker_pk;

COMMENT ON TABLE registry.docker IS 'Вычислительный модуль молекулярного докинга';
COMMENT ON COLUMN registry.docker.id IS 'Идентификатор модуля';
COMMENT ON COLUMN registry.docker.name IS 'Название модуля';
COMMENT ON COLUMN registry.docker.system_name IS 'Внутреннее имя';
COMMENT ON COLUMN registry.docker.description IS 'Описание модуля';

-- Последовательность для нумерации модулей
CREATE SEQUENCE registry.seq_docker_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень версий модулей моделирования докинга
CREATE TABLE registry.docker_version
(
	id             INT NOT NULL,
	docker_id      INT NOT NULL,
	version_number DOUBLE PRECISION
);

CREATE UNIQUE INDEX idx_docker_version_pk ON registry.docker_version(id);
CREATE INDEX idx_docker_version_docker_fk ON registry.docker_version(docker_id);
CREATE UNIQUE INDEX idx_docker_version_number_uq ON registry.docker_version(docker_id, version_number);
ALTER TABLE registry.docker_version ADD CONSTRAINT cs_docker_version_pk PRIMARY KEY USING INDEX idx_docker_version_pk;
ALTER TABLE registry.docker_version ADD CONSTRAINT cs_docker_version_docker_fk FOREIGN KEY(docker_id) REFERENCES registry.docker(id);
ALTER TABLE registry.docker_version ADD CONSTRAINT cs_docker_version_version_number_uq UNIQUE(docker_id, version_number);

COMMENT ON TABLE registry.docker_version IS 'Версия вычислительного модуля';
COMMENT ON COLUMN registry.docker_version.id IS 'Идентификатор версии вычислительного модуля';
COMMENT ON COLUMN registry.docker_version.docker_id IS 'Идентификатор вычислительного модуля';
COMMENT ON COLUMN registry.docker_version.version_number IS 'Версия вычислительного модуля';

-- Последовательность для нумерации версий модулей
CREATE SEQUENCE registry.seq_docker_version_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень протоколов молекулярного докинга
CREATE TABLE registry.docker_protocol
(
    id          INT NOT NULL,
    name        VARCHAR(256) NOT NULL,
    system_name VARCHAR(64) NOT NULL,
    description VARCHAR(1024) NOT NULL
);

CREATE UNIQUE INDEX idx_docker_protocol_pk ON registry.docker_protocol(id);
ALTER TABLE registry.docker_protocol ADD CONSTRAINT cs_docker_protocol_pk PRIMARY KEY USING INDEX idx_docker_protocol_pk;

COMMENT ON TABLE registry.docker_protocol IS 'Набор параметров для создания новых задач';
COMMENT ON COLUMN registry.docker_protocol.id IS 'Идентификатор набора параметров';
COMMENT ON COLUMN registry.docker_protocol.name IS 'Название набора параметров';
COMMENT ON COLUMN registry.docker_protocol.system_name IS 'Внутреннее имя';
COMMENT ON COLUMN registry.docker_protocol.description IS 'Описание набора параметров';

-- Последовательность для нумерации протоколов
CREATE SEQUENCE registry.seq_docker_protocol_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Элемент из набора параметров
CREATE TABLE registry.docker_protocol_item
(
    id                 INT NOT NULL,
    docker_protocol_id INT NOT NULL,
    docking_app        VARCHAR(16) NOT NULL,
    type               VARCHAR(32) NOT NULL,
    order_number       INT NOT NULL,
    file_path          VARCHAR(256) NOT NULL,
    file_name          VARCHAR(256) NOT NULL
);

CREATE UNIQUE INDEX idx_docker_protocol_item_pk ON registry.docker_protocol_item(id);
CREATE INDEX idx_docker_protocol_item_docker_protocol_fk ON registry.docker_protocol_item(id);
ALTER TABLE registry.docker_protocol_item ADD CONSTRAINT cs_docker_protocol_item_pk PRIMARY KEY USING INDEX idx_docker_protocol_item_pk;
ALTER TABLE registry.docker_protocol_item ADD CONSTRAINT cs_docker_protocol_item_docker_protocol_fk FOREIGN KEY(docker_protocol_id) REFERENCES registry.docker_protocol(id) ON DELETE CASCADE;
ALTER TABLE registry.docker_protocol_item ADD CONSTRAINT cs_docker_protocol_item_docking_app_ck CHECK (docking_app IN('cmdock', 'autodockvina'));
ALTER TABLE registry.docker_protocol_item ADD CONSTRAINT cs_docker_protocol_item_type_ck CHECK (type IN('TemplateIn', 'TemplateOut', 'CmDockTargetMOL2', 'CmDockConfigPRM', 'CmDockConfigAS', 'CmDockConfigPTC', 'AutoDockVinaTargetPDBQT', 'AutoDockVinaConfigTXT'));

COMMENT ON TABLE registry.docker_protocol_item IS 'Элемент набора параметров для создания новых задач';
COMMENT ON COLUMN registry.docker_protocol_item.id IS 'Идентификатор элемента набора параметров';
COMMENT ON COLUMN registry.docker_protocol_item.docker_protocol_id IS 'Идентификатор набора параметров';
COMMENT ON COLUMN registry.docker_protocol_item.docking_app IS 'Название приложения молекулярного докинга';
COMMENT ON COLUMN registry.docker_protocol_item.type IS 'Тип элемента';
COMMENT ON COLUMN registry.docker_protocol_item.order_number IS 'Порядковый номер, по которому файлы надо будет упорядочивать в команде создания задач';
COMMENT ON COLUMN registry.docker_protocol_item.file_path IS 'Путь к файлу';
COMMENT ON COLUMN registry.docker_protocol_item.file_name IS 'Имя файла';

-- Последовательность для нумерации элементов наборов параметров для создания задач
CREATE SEQUENCE registry.seq_docker_protocol_item_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Пакет с лигандами
CREATE TABLE registry.package
(
	id           INT NOT NULL,
	library_id   INT NOT NULL,
	file_name    VARCHAR(256) NOT NULL,
	file_path    VARCHAR(256) NOT NULL,
	ligand_count INT NOT NULL,
	docker_id    INT NOT NULL 
);

CREATE UNIQUE INDEX idx_package_pk ON registry.package(id);
CREATE INDEX idx_package_library_fk ON registry.package(library_id);
CREATE INDEX idx_package_docker_fk ON registry.package(docker_id);
ALTER TABLE registry.package ADD CONSTRAINT cs_package_pk PRIMARY KEY USING INDEX idx_package_pk;
ALTER TABLE registry.package ADD CONSTRAINT cs_package_library_fk FOREIGN KEY(library_id) REFERENCES registry.library(id);
ALTER TABLE registry.package ADD CONSTRAINT cs_package_docker_fk FOREIGN KEY(docker_id) REFERENCES registry.docker(id);

COMMENT ON TABLE registry.package IS 'Пакет с лигандами';
COMMENT ON COLUMN registry.package.id IS 'Идентификатор пакета';
COMMENT ON COLUMN registry.package.library_id IS 'Идентификатор библиотеки';
COMMENT ON COLUMN registry.package.file_name IS 'Имя файла с пакетом лигандов';
COMMENT ON COLUMN registry.package.file_path IS 'Путь к файлу с пакетом лигандов';
COMMENT ON COLUMN registry.package.ligand_count IS 'Количество лигандов в пакете';
COMMENT ON COLUMN registry.package.docker_id IS 'Идентификатор модуля докинга';

-- Последовательность для нумерации пакетов с лигандами
CREATE SEQUENCE registry.seq_package_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень протоколов виртуального скрининга
CREATE TABLE registry.search_protocol
(
	id                            INT NOT NULL,
	hit_criterion                 CHAR(1) NOT NULL,
	stop_criterion                CHAR(1) NOT NULL,
	hit_threshold_energy          NUMERIC,
	hit_threshold_efficiency      NUMERIC,
	stop_fraction_ligands         NUMERIC,
	stop_count_hits               INT,
	stop_fraction_hits            NUMERIC,
	is_notify_hits                BOOLEAN,
	is_notify_fraction_ligands    BOOLEAN,
	value_notify_fraction_ligands NUMERIC
);

CREATE UNIQUE INDEX idx_search_protocol_pk ON registry.search_protocol(id);
ALTER TABLE registry.search_protocol ADD CONSTRAINT cs_search_protocol_pk PRIMARY KEY USING INDEX idx_search_protocol_pk;

COMMENT ON TABLE registry.search_protocol IS 'Протокол виртуального скрининга';
COMMENT ON COLUMN registry.search_protocol.hit_criterion IS 'Критерий отбора хитов: N - энергия связывания (energy), F - эффективность лиганда (ligand efficiency)';
COMMENT ON COLUMN registry.search_protocol.stop_criterion IS 'Критерий остановки: L - доля проверенных лигандов, H - число найденных хитов, F - доля хитов';
COMMENT ON COLUMN registry.search_protocol.hit_threshold_energy IS 'Порог энергии связывания';
COMMENT ON COLUMN registry.search_protocol.hit_threshold_efficiency IS 'Порог эффективности лиганда';
COMMENT ON COLUMN registry.search_protocol.stop_fraction_ligands IS 'Доля проверенных лигандов';
COMMENT ON COLUMN registry.search_protocol.stop_count_hits IS 'Число найденных хитов';
COMMENT ON COLUMN registry.search_protocol.stop_fraction_hits IS 'Доля хитов от числа лигандов';
COMMENT ON COLUMN registry.search_protocol.is_notify_hits IS 'Флаг оповещения о найденных хитах';
COMMENT ON COLUMN registry.search_protocol.is_notify_fraction_ligands IS 'Флаг оповещения о доле обработанных лигандов';
COMMENT ON COLUMN registry.search_protocol.value_notify_fraction_ligands IS 'Доля обработанных лигандов для оповещения';

-- Последовательность для нумерации протоколов
CREATE SEQUENCE registry.seq_search_protocol_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Поиск (виртуальный скрининг лекарств, вычислительный эксперимент)
CREATE TABLE registry.search
(
	id                 INT NOT NULL,
	create_time        TIMESTAMP NOT NULL,
	name               VARCHAR(256) NOT NULL,
	system_name        VARCHAR(64) NOT NULL,
	description        VARCHAR(1024) NOT NULL,
	target_id          INT NOT NULL,
	library_id         INT NOT NULL,
	docker_id          INT NOT NULL,
	docker_protocol_id INT NOT NULL,
	search_protocol_id INT NOT NULL,
	host_usage_type    CHAR(1) NOT NULL,
	prefix             VARCHAR(32) NOT NULL,
	state              CHAR(1) NOT NULL,
        status             CHAR(1) NOT NULL DEFAULT 'A'
);

CREATE UNIQUE INDEX idx_search_pk ON registry.search(id);
CREATE INDEX idx_search_target_fk ON registry.search(target_id);
CREATE INDEX idx_search_library_fk ON registry.search(library_id);
CREATE INDEX idx_search_docker_fk ON registry.search(docker_id);
CREATE INDEX idx_search_docker_protocol_fk ON registry.search(docker_protocol_id);
CREATE INDEX idx_search_search_protocol_fk ON registry.search(search_protocol_id);

ALTER TABLE registry.search ADD CONSTRAINT cs_search_pk PRIMARY KEY USING INDEX idx_search_pk;
ALTER TABLE registry.search ADD CONSTRAINT cs_search_target_fk FOREIGN KEY(target_id) REFERENCES registry.target(id);
ALTER TABLE registry.search ADD CONSTRAINT cs_search_library_fk FOREIGN KEY(library_id) REFERENCES registry.library(id);
ALTER TABLE registry.search ADD CONSTRAINT cs_search_docker_fk FOREIGN KEY(docker_id) REFERENCES registry.docker(id);
ALTER TABLE registry.search ADD CONSTRAINT cs_search_docker_protocol_fk FOREIGN KEY(docker_protocol_id) REFERENCES registry.docker_protocol(id);
ALTER TABLE registry.search ADD CONSTRAINT cs_search_search_protocol_fk FOREIGN KEY(search_protocol_id) REFERENCES registry.search_protocol(id);
ALTER TABLE registry.search ADD CONSTRAINT cs_search_host_usage_type_ck CHECK (host_usage_type IN('T', 'R', 'P')); 
ALTER TABLE registry.search ADD CONSTRAINT cs_search_state_ck CHECK (state IN('P', 'U', 'L', 'A')); 
ALTER TABLE registry.search ADD CONSTRAINT cs_search_status_ck CHECK (status IN('A', 'F'));

COMMENT ON TABLE registry.search IS 'Поиск';
COMMENT ON COLUMN registry.search.id IS 'Идентификатор';
COMMENT ON COLUMN registry.search.name IS 'Название';
COMMENT ON COLUMN registry.search.description IS 'Описание';
COMMENT ON COLUMN registry.search.target_id IS 'Идентификатор мишени';
COMMENT ON COLUMN registry.search.library_id IS 'Идентификатор библиотеки';
COMMENT ON COLUMN registry.search.docker_id IS 'Идентификатор вычислительного модуля';
COMMENT ON COLUMN registry.search.docker_protocol_id IS 'Идентификатор набора параметров молекулярного докинга';
COMMENT ON COLUMN registry.search.search_protocol_id IS 'Идентификатор набора параметров виртаульного скрининга';
COMMENT ON COLUMN registry.search.prefix IS 'Приставка, выделяющая задачи этого поиска среди иных';
COMMENT ON COLUMN registry.search.host_usage_type IS 'Тип вычислительных ресурсов: T - тестовые (test); R - частные (private); P - общие (public)';
COMMENT ON COLUMN registry.search.state IS 'Состояние поиска: P - создается (preparing); U - не заблокирован, можно изменять и удалять (unlocked); L - заблокирован - используется в поисках (locked); A - архивация, данные выносятся в архив (archived)';
COMMENT ON COLUMN registry.search.status IS 'Статус поиска: A - активен, F - завершен';

-- Последовательность для нумерации поисков
CREATE SEQUENCE registry.seq_search_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;

-- Химические свойства лигандов
CREATE TABLE registry.ligand
(
        id                      INT NOT NULL,
        library_id              INT NOT NULL,
        package_id              INT,
        name                    VARCHAR(256) NOT NULL,
        ligand_formula          VARCHAR(256),
        ligand_mol_weight       NUMERIC,
        ligand_exact_mass       NUMERIC,
        ligand_canonical_smiles VARCHAR(256),
        ligand_inchi            VARCHAR(128),
        ligand_num_atoms        SMALLINT,
        ligand_num_bonds        SMALLINT,
        ligand_num_residues     SMALLINT, 
        ligand_sequence         VARCHAR(256),
        ligand_num_rings        SMALLINT,
        ligand_logp             NUMERIC,
        ligand_psa              NUMERIC,
        ligand_mr               NUMERIC
);

CREATE UNIQUE INDEX idx_ligand_pk ON registry.ligand(id);
CREATE UNIQUE INDEX idx_ligand_library_name_uq ON registry.ligand(library_id, name);

ALTER TABLE registry.ligand ADD CONSTRAINT cs_ligand_pk PRIMARY KEY USING INDEX idx_ligand_pk;

COMMENT ON TABLE registry.ligand IS 'Химические свойства лигандов';
COMMENT ON COLUMN registry.ligand.id IS 'Идентификатор лиганда';
COMMENT ON COLUMN registry.ligand.library_id IS 'Идентификатор библиотеки лигандов';
COMMENT ON COLUMN registry.ligand.package_id IS 'Идентификатор пакета лигандов'; 
COMMENT ON COLUMN registry.ligand.name IS 'Имя лиганда'; 
COMMENT ON COLUMN registry.ligand.ligand_formula IS 'Формула';
COMMENT ON COLUMN registry.ligand.ligand_mol_weight IS 'Молекулярная масса'; 
COMMENT ON COLUMN registry.ligand.ligand_exact_mass IS 'Точная молекулярная масса';
COMMENT ON COLUMN registry.ligand.ligand_canonical_smiles IS 'Каноническая строка SMILES';
COMMENT ON COLUMN registry.ligand.ligand_inchi IS 'IUPAC InChI identifier';
COMMENT ON COLUMN registry.ligand.ligand_num_atoms IS 'Число атомов';
COMMENT ON COLUMN registry.ligand.ligand_num_bonds IS 'Число связей';
COMMENT ON COLUMN registry.ligand.ligand_num_residues IS 'Число остатков';
COMMENT ON COLUMN registry.ligand.ligand_sequence IS 'Последовательность';
COMMENT ON COLUMN registry.ligand.ligand_num_rings IS 'Число циклов';
COMMENT ON COLUMN registry.ligand.ligand_logp IS 'Octanol/water partition coefficient';
COMMENT ON COLUMN registry.ligand.ligand_psa IS 'Polar surface area';
COMMENT ON COLUMN registry.ligand.ligand_mr IS 'Molar refractivity';

-- Последовательность для нумерации лигандов
CREATE SEQUENCE registry.seq_ligand_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень примеров виртуального скрининга
CREATE TABLE registry.example
(
	id                 INT NOT NULL,
	name               VARCHAR(32) NOT NULL,
	is_ready           BOOLEAN NOT NULL,
	target_id          INT NOT NULL,
	library_id         INT NOT NULL,
	docker_id          INT NOT NULL,
	docker_protocol_id INT NOT NULL,
	search_protocol_id INT NOT NULL,
	host_usage_type    CHAR(1) NOT NULL
);

CREATE UNIQUE INDEX idx_example_pk ON registry.example(id);
CREATE INDEX idx_example_target_fk ON registry.example(target_id);
CREATE INDEX idx_example_library_fk ON registry.example(library_id);
CREATE INDEX idx_example_docker_fk ON registry.example(docker_id);
CREATE INDEX idx_example_docker_protocol_fk ON registry.example(docker_protocol_id);
CREATE INDEX idx_example_search_protocol_fk ON registry.example(search_protocol_id);

ALTER TABLE registry.example ADD CONSTRAINT cs_example_pk PRIMARY KEY USING INDEX idx_example_pk;
ALTER TABLE registry.example ADD CONSTRAINT cs_example_target_fk FOREIGN KEY(target_id) REFERENCES registry.target(id);
ALTER TABLE registry.example ADD CONSTRAINT cs_example_library_fk FOREIGN KEY(library_id) REFERENCES registry.library(id);
ALTER TABLE registry.example ADD CONSTRAINT cs_example_docker_fk FOREIGN KEY(docker_id) REFERENCES registry.docker(id);
ALTER TABLE registry.example ADD CONSTRAINT cs_example_docker_protocol_fk FOREIGN KEY(docker_protocol_id) REFERENCES registry.docker_protocol(id);
ALTER TABLE registry.example ADD CONSTRAINT cs_example_search_protocol_fk FOREIGN KEY(search_protocol_id) REFERENCES registry.search_protocol(id);

COMMENT ON TABLE registry.example IS 'Пример';
COMMENT ON COLUMN registry.example.id IS 'Идентификатор';
COMMENT ON COLUMN registry.example.name IS 'Название';
COMMENT ON COLUMN registry.example.target_id IS 'Идентификатор мишени';
COMMENT ON COLUMN registry.example.library_id IS 'Идентификатор библиотеки';
COMMENT ON COLUMN registry.example.docker_id IS 'Идентификатор вычислительного модуля';
COMMENT ON COLUMN registry.example.docker_protocol_id IS 'Идентификатор набора параметров молекулярного докинга';
COMMENT ON COLUMN registry.example.search_protocol_id IS 'Идентификатор набора параметров виртаульного скрининга';
COMMENT ON COLUMN registry.example.host_usage_type IS 'Тип вычислительных ресурсов: T - тестовые (test); R - частные (private); P - общие (public)';

-- Последовательность для нумерации примеров
CREATE SEQUENCE registry.seq_example_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Состояние задачи
CREATE TABLE registry.workunit_state
(
	id          INT NOT NULL,
	name        VARCHAR(64) NOT NULL,
	description VARCHAR(1024) NOT NULL
);

CREATE UNIQUE INDEX idx_workunit_state_pk ON registry.workunit_state(id);
ALTER TABLE registry.workunit_state ADD CONSTRAINT cs_workunit_state_pk PRIMARY KEY USING INDEX idx_workunit_state_pk;

COMMENT ON TABLE registry.workunit_state IS 'Состояние задачи';
COMMENT ON COLUMN registry.workunit_state.id IS 'Идентификатор состояния';
COMMENT ON COLUMN registry.workunit_state.name IS 'Название состояния';
COMMENT ON COLUMN registry.workunit_state.description IS 'Описание состояния';


-- Перечень задач
CREATE TABLE registry.workunit
(
    id                INT NOT NULL,
    create_time       TIMESTAMP NOT NULL,
    name              VARCHAR(64) NOT NULL,
    search_id         INT NOT NULL,
    package_id        INT NOT NULL,
    docker_version_id INT NOT NULL,
    state_id          INT NOT NULL    
);

CREATE UNIQUE INDEX idx_workunit_pk ON registry.workunit(id);
CREATE INDEX idx_workunit_search_fk ON registry.workunit(search_id);
CREATE INDEX idx_workunit_package_fk ON registry.workunit(package_id);
CREATE INDEX idx_workunit_docker_version_fk ON registry.workunit(docker_version_id);
CREATE INDEX idx_workunit_state_status_fk ON registry.workunit(state_id);
ALTER TABLE registry.workunit ADD CONSTRAINT cs_workunit_pk PRIMARY KEY USING INDEX idx_workunit_pk;
ALTER TABLE registry.workunit ADD CONSTRAINT cs_workunit_search_fk FOREIGN KEY(search_id) REFERENCES registry.search(id) ON DELETE CASCADE;
ALTER TABLE registry.workunit ADD CONSTRAINT cs_workunit_package_fk FOREIGN KEY(package_id) REFERENCES registry.package(id);
ALTER TABLE registry.workunit ADD CONSTRAINT cs_workunit_docker_version_fk FOREIGN KEY(docker_version_id) REFERENCES registry.docker_version(id);
ALTER TABLE registry.workunit ADD CONSTRAINT cs_workunit_state_fk FOREIGN KEY(state_id) REFERENCES registry.workunit_state(id);

COMMENT ON TABLE registry.workunit IS 'Задача';
COMMENT ON COLUMN registry.workunit.id IS 'Идентификатор задачи';
COMMENT ON COLUMN registry.workunit.create_time IS 'Время создания';
COMMENT ON COLUMN registry.workunit.name IS 'Название задачи';
COMMENT ON COLUMN registry.workunit.search_id IS 'Идентификатор поиска';
COMMENT ON COLUMN registry.workunit.package_id IS 'Идентификатор пакета с лигандами, обрабатываемый в рамках задачи';
COMMENT ON COLUMN registry.workunit.docker_version_id IS 'Идентификатор версии вычислительного модуля';
COMMENT ON COLUMN registry.workunit.state_id IS 'Идентификатор состояния задачи';

-- Последовательность для идентификации задач
CREATE SEQUENCE registry.seq_workunit_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Пользователь
CREATE TABLE registry.user
(
    id                  INT NOT NULL,
    create_time         TIMESTAMP NOT NULL,	
    login               VARCHAR(64) NOT NULL,
    email               VARCHAR(64) NOT NULL,
    password_hash       VARCHAR(32),
    name                VARCHAR(64),
    description         VARCHAR(256),
    state               CHAR(1) NOT NULL,
    boinc_user_id       INT,
    boinc_authenticator VARCHAR(32),
    boinc_password      VARCHAR(32)
);

CREATE UNIQUE INDEX idx_user_pk ON registry.user(id);
ALTER TABLE registry.user ADD CONSTRAINT cs_user_pk PRIMARY KEY USING INDEX idx_user_pk;
ALTER TABLE registry.user ADD CONSTRAINT cs_user_state_ck CHECK (state IN('U', 'L', 'A', 'N')); 

COMMENT ON TABLE registry.user IS 'Пользователь';
COMMENT ON COLUMN registry.user.id IS 'Идентификатор пользователя';
COMMENT ON COLUMN registry.user.create_time IS 'Время создания';
COMMENT ON COLUMN registry.user.login IS 'Логин пользователя';
COMMENT ON COLUMN registry.user.email IS 'E-mail пользователя';
COMMENT ON COLUMN registry.user.password_hash IS 'Хэш пароля';
COMMENT ON COLUMN registry.user.name IS 'Имя пользователя';
COMMENT ON COLUMN registry.user.description IS 'Описание пользователя';
COMMENT ON COLUMN registry.user.state IS 'Состояние учётной записи пользователя:  U - не заблокирован, можно изменять и удалять (unlocked); L - заблокирован - используется в поисках (locked); A - архивация, данные выносятся в архив (archived); N - не подтвержден (new)';
COMMENT ON COLUMN registry.user.boinc_user_id IS 'Идентификатор пользователя в BOINC-сервере';
COMMENT ON COLUMN registry.user.boinc_authenticator IS 'Ключ к учётной записи в BOINC-сервере';
COMMENT ON COLUMN registry.user.boinc_password IS 'Пароль к BOINC-серверу';

-- Последовательность для идентификации пользователей
CREATE SEQUENCE registry.seq_user_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Роль
CREATE TABLE registry.role 
(
    id          INT NOT NULL,
    name        VARCHAR(64) NOT NULL,
    description VARCHAR(1024)
);

CREATE UNIQUE INDEX idx_role_pk ON registry.role(id);
ALTER TABLE registry.role ADD CONSTRAINT cs_role_pk PRIMARY KEY USING INDEX idx_role_pk;

COMMENT ON TABLE registry.role IS 'Роль пользователя';
COMMENT ON COLUMN registry.role.id IS 'Идентификатор роли';
COMMENT ON COLUMN registry.role.name IS 'Название роли';
COMMENT ON COLUMN registry.role.description IS 'Описание роли';

-- Последовательность для идентификации ролей
CREATE SEQUENCE registry.seq_role_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Привилегия
CREATE TABLE registry.privilege
(
    id          INT NOT NULL,
    name        VARCHAR(64) NOT NULL,
    type        CHAR(1) NOT NULL,
    description VARCHAR(1024) NOT NULL
);

CREATE UNIQUE INDEX idx_privilege_pk ON registry.privilege(id);
ALTER TABLE registry.privilege ADD CONSTRAINT cs_privilege_pk PRIMARY KEY USING INDEX idx_privilege_pk;
ALTER TABLE registry.privilege ADD CONSTRAINT cs_privilege_type_ck CHECK (type IN('S', 'O'));

COMMENT ON TABLE registry.privilege IS 'Привилегия';
COMMENT ON COLUMN registry.privilege.id IS 'Идентификатор привилегии';
COMMENT ON COLUMN registry.privilege.type IS 'Вид привилегии';
COMMENT ON COLUMN registry.privilege.name IS 'Название привилегии';
COMMENT ON COLUMN registry.privilege.description IS 'Описание привилегии';


-- Привилегия, назначенная роли
CREATE TABLE registry.role_privilege
(
    id           INT NOT NULL,
    role_id      INT NOT NULL,
    privilege_id INT NOT NULL,
    object_id    INT
);

CREATE UNIQUE INDEX idx_role_privilege_pk ON registry.role_privilege(id);
CREATE UNIQUE INDEX idx_role_privilege_grant_uq ON registry.role_privilege(role_id, privilege_id, object_id);
CREATE INDEX idx_role_privilege_role_fk ON registry.role_privilege(role_id);
CREATE INDEX idx_role_privilege_privilege_fk ON registry.role_privilege(privilege_id);
ALTER TABLE registry.role_privilege ADD CONSTRAINT cs_role_privilege_pk PRIMARY KEY USING INDEX idx_role_privilege_pk;
ALTER TABLE registry.role_privilege ADD CONSTRAINT cs_role_privilege_uq UNIQUE USING INDEX idx_role_privilege_grant_uq;
ALTER TABLE registry.role_privilege ADD CONSTRAINT cs_role_privilege_role_fk FOREIGN KEY(role_id) REFERENCES registry.role(id);
ALTER TABLE registry.role_privilege ADD CONSTRAINT cs_role_privilege_privilege_fk FOREIGN KEY(role_id) REFERENCES registry.privilege(id);

COMMENT ON TABLE registry.role_privilege IS 'Привилегия, выданная роли';
COMMENT ON COLUMN registry.role_privilege.id IS 'Идентификатор связки "роль-привилегия"';
COMMENT ON COLUMN registry.role_privilege.role_id IS 'Идентификатор роли';
COMMENT ON COLUMN registry.role_privilege.privilege_id IS 'Идентификатор привилегии';
COMMENT ON COLUMN registry.role_privilege.object_id IS 'Идентификатор объекта (в случае объектой привилегии';

-- Последовательность для идентификации привилегий, выданных ролям
CREATE SEQUENCE registry.seq_role_privilege_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Роль, назначенная пользователю
CREATE TABLE registry.user_role
(
    id      INT NOT NULL,
    user_id INT NOT NULL,
    role_id INT NOT NULL
);

CREATE UNIQUE INDEX idx_user_role_pk ON registry.user_role(id);
CREATE UNIQUE INDEX idx_user_role_grant_uq ON registry.user_role(user_id, role_id);
CREATE INDEX idx_user_role_user_fk ON registry.user_role(user_id);
CREATE INDEX idx_user_role_role_fk ON registry.user_role(role_id);
ALTER TABLE registry.user_role ADD CONSTRAINT cs_user_role_pk PRIMARY KEY USING INDEX idx_user_role_pk;
ALTER TABLE registry.user_role ADD CONSTRAINT cs_user_role_grant_uq UNIQUE USING INDEX idx_user_role_grant_uq;
ALTER TABLE registry.user_role ADD CONSTRAINT cs_user_role_user_fk FOREIGN KEY(user_id) REFERENCES registry.user(id);
ALTER TABLE registry.user_role ADD CONSTRAINT cs_user_role_role_fk FOREIGN KEY(role_id) REFERENCES registry.role(id);

COMMENT ON TABLE registry.user_role IS 'Роль, выданная пользователю';
COMMENT ON COLUMN registry.user_role.id IS 'Идентификатор связки "пользователь - роль"';
COMMENT ON COLUMN registry.user_role.user_id IS 'Идентификатор пользователя';
COMMENT ON COLUMN registry.user_role.role_id IS 'Идентификатор роли';

-- Последовательность для идентификации ролей, выданных пользователям
CREATE SEQUENCE registry.seq_user_role_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Компьютер, подключенный к вычислениям
CREATE TABLE registry.host
(
    id                INT NOT NULL,
    create_time       TIMESTAMP NOT NULL,	
    name              VARCHAR(64),
    user_id           INT NOT NULL,
    boinc_host_id     INT NOT NULL,
    host_usage_type   CHAR(1) NOT NULL,
    tasks_progress    INT NOT NULL DEFAULT 0,
    tasks_completed   INT NOT NULL DEFAULT 0,
    last_request_time TIMESTAMP
);

CREATE UNIQUE INDEX idx_host_pk ON registry.host(id);
CREATE INDEX idx_host_user_fk ON registry.host(user_id);
CREATE UNIQUE INDEX idx_boinc_host_id_uq ON registry.host(boinc_host_id);
ALTER TABLE registry.host ADD CONSTRAINT cs_host_pk PRIMARY KEY USING INDEX idx_host_pk;
ALTER TABLE registry.host ADD CONSTRAINT cs_host_owner_fk FOREIGN KEY(user_id) REFERENCES registry.user(id);

COMMENT ON TABLE registry.host IS 'Компьютер';
COMMENT ON COLUMN registry.host.id IS 'Идентификатор компьютера';
COMMENT ON COLUMN registry.host.create_time IS 'Время создания';
COMMENT ON COLUMN registry.host.name IS 'Имя';
COMMENT ON COLUMN registry.host.user_id IS 'Идентификатор пользователя';
COMMENT ON COLUMN registry.host.boinc_host_id IS 'Идентификатор компьютера из BOINC-проекта';
COMMENT ON COLUMN registry.host.host_usage_type IS 'Тип вычислительного ресурса: T - тестовый (test); R - частный (private); P - общий (public)';
COMMENT ON COLUMN registry.host.tasks_progress IS 'Число заданий, выполняющихся на компьютере в данный момент';
COMMENT ON COLUMN registry.host.tasks_completed IS 'Число заданий, завершенных компьютером';
COMMENT ON COLUMN registry.host.last_request_time IS 'Время последнего обращения к серверу';

-- Последовательность для идентификации компьютеров
CREATE SEQUENCE registry.seq_host_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень типов оповещений 
CREATE TABLE registry.notification_type
(
	id          INT NOT NULL,
	name        VARCHAR(32) NOT NULL,
	description VARCHAR(1024) NOT NULL
);

CREATE UNIQUE INDEX idx_notification_type_pk ON registry.notification_type(id);
ALTER TABLE registry.notification_type ADD CONSTRAINT cs_notification_type_pk PRIMARY KEY USING INDEX idx_notification_type_pk;

COMMENT ON TABLE registry.notification_type IS 'Тип оповещения';
COMMENT ON COLUMN registry.notification_type.id IS 'Идентификатор';
COMMENT ON COLUMN registry.notification_type.name IS 'Название';
COMMENT ON COLUMN registry.notification_type.description IS 'Описание';

-- Последовательность для нумерации типов оповещений
CREATE SEQUENCE registry.seq_notification_type_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень шаблонов оповещений 
CREATE TABLE registry.notification_template
(
	id          INT NOT NULL,
	type_id	    INT NOT NULL,
	description VARCHAR(1024) NOT NULL,
	title       VARCHAR(256) NOT NULL,
	content     VARCHAR(1024) NOT NULL
);

CREATE UNIQUE INDEX idx_notification_template_pk ON registry.notification_template(id);
CREATE INDEX idx_notification_template_type_fk ON registry.notification_template(type_id);
ALTER TABLE registry.notification_template ADD CONSTRAINT cs_notification_template_pk PRIMARY KEY USING INDEX idx_notification_template_pk;
ALTER TABLE registry.notification_template ADD CONSTRAINT cs_notification_type_fk FOREIGN KEY(type_id) REFERENCES registry.notification_type(id);

COMMENT ON TABLE registry.notification_template IS 'Шаблон оповещения';
COMMENT ON COLUMN registry.notification_template.id IS 'Идентификатор';
COMMENT ON COLUMN registry.notification_template.id IS 'Тип оповещения';
COMMENT ON COLUMN registry.notification_template.description IS 'Описание';
COMMENT ON COLUMN registry.notification_template.title IS 'Заголовок оповещения';
COMMENT ON COLUMN registry.notification_template.content IS 'Текст оповещения';

-- Последовательность для нумерации шаблонов оповещений
CREATE SEQUENCE registry.seq_notification_template_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Перечень оповещений 
CREATE TABLE registry.notification
(
	id	    INT NOT NULL,
	user_id	    INT NOT NULL,
	create_time TIMESTAMP NOT NULL,
	type_id	    INT NOT NULL,
	title       VARCHAR(256) NOT NULL,
	content     VARCHAR(1024) NOT NULL,
	is_read     BOOLEAN NOT NULL,
	is_trash    BOOLEAN NOT NULL
);

CREATE UNIQUE INDEX idx_notification_pk ON registry.notification(id);
CREATE INDEX idx_notification_user_fk ON registry.notification(user_id);
CREATE INDEX idx_notification_type_fk ON registry.notification(type_id);
ALTER TABLE registry.notification ADD CONSTRAINT cs_notification_pk PRIMARY KEY USING INDEX idx_notification_pk;
ALTER TABLE registry.notification ADD CONSTRAINT cs_notification_user_fk FOREIGN KEY(user_id) REFERENCES registry.user(id);
ALTER TABLE registry.notification ADD CONSTRAINT cs_notification_type_fk FOREIGN KEY(type_id) REFERENCES registry.notification_type(id);

COMMENT ON TABLE registry.notification IS 'Оповещение';
COMMENT ON COLUMN registry.notification.id IS 'Идентификатор';
COMMENT ON COLUMN registry.notification.create_time IS 'Время создания';
COMMENT ON COLUMN registry.notification.type_id IS 'Тип оповещения';
COMMENT ON COLUMN registry.notification.title IS 'Заголовок оповещения';
COMMENT ON COLUMN registry.notification.content IS 'Текст оповещения';
COMMENT ON COLUMN registry.notification.is_read IS 'Флаг того, что оповещение прочитано';
COMMENT ON COLUMN registry.notification.is_trash IS 'Флаг того, что оповещение удалено';

-- Последовательность для нумерации оповещений
CREATE SEQUENCE registry.seq_notification_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Представление "Задачи для создания в проекте"
CREATE OR REPLACE VIEW registry.vw_workunit_to_generate AS
SELECT workunit.id AS workunit_id,
       workunit.search_id AS search_id,
       search.docker_protocol_id AS docker_protocol_id,
       workunit.name AS workunit_name,
       target_file.file_name AS target_file_name,
       target_file.file_path AS target_file_path,
       package.file_name AS package_file_name,
       package.file_path AS package_file_path,
       docker.system_name AS application_system_name,
       search.host_usage_type AS resource_type,
       TRIM(TO_CHAR(docker_version.version_number*100, '9999')) AS application_version
  FROM registry.workunit_state
  JOIN registry.workunit ON workunit.state_id = workunit_state.id
  JOIN registry.docker_version ON docker_version.id = workunit.docker_version_id
  JOIN registry.docker ON docker.id = docker_version.docker_id
  JOIN registry.search ON search.id = workunit.search_id
  JOIN registry.target_file ON target_file.target_id = search.target_id AND 
	(docker.system_name = 'cmdock' AND target_file.TYPE = 'mol2' OR docker.system_name = 'autodockvina' AND target_file.TYPE = 'pdbqt')
  JOIN registry.package ON package.id = workunit.package_id AND package.docker_id = docker.id
 WHERE workunit_state.name = 'GENERATED';


-- Таблица для связи сущностей frontend - backend
CREATE TABLE registry.entity_mapping
(
    id              INT NOT NULL,
    front_entity_id INT NOT NULL,
    back_entity_id  INT NOT NULL,
    entity_type     CHAR(1) NOT NULL
);

CREATE UNIQUE INDEX idx_entity_mapping_pk ON registry.entity_mapping(id);
CREATE UNIQUE INDEX idx_front_type_un ON registry.entity_mapping(front_entity_id, entity_type);
CREATE UNIQUE INDEX idx_back_type_un ON registry.entity_mapping(back_entity_id, entity_type);

ALTER TABLE registry.entity_mapping ADD CONSTRAINT cs_entity_mapping_pk PRIMARY KEY USING INDEX idx_entity_mapping_pk;
ALTER TABLE registry.entity_mapping ADD CONSTRAINT cs_entity_mapping_entity_type_ck CHECK(entity_type IN('T', 'L', 'S'));

COMMENT ON TABLE registry.entity_mapping IS 'Связь сущностей frontend - backend';
COMMENT ON COLUMN registry.entity_mapping.id IS 'Идентификатор связи сущностей';
COMMENT ON COLUMN registry.entity_mapping.front_entity_id IS 'Идентификатор frontend-сущности';
COMMENT ON COLUMN registry.entity_mapping.back_entity_id IS 'Идентификатор backend-сущности';
COMMENT ON COLUMN registry.entity_mapping.entity_type IS 'Тип сущности: T - мишень (target); L - библиотека лигандов (library); S - поиск (search)';

-- Последовательность для нумерации связей сущностей
CREATE SEQUENCE registry.seq_entity_mapping_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;


-- Объекты справочника "Системные параметры HiTViSc", ссылающегося на файл /app/hitvisc/main/hitvisc.conf
-- Создание "сервера" для работы с локальными файлами
CREATE SERVER srv_local_file FOREIGN DATA WRAPPER file_fdw;

-- Создание внешней таблицы с перечнем параметров
CREATE FOREIGN TABLE registry.system_parameter
(
    name TEXT,
    value TEXT
)
SERVER srv_local_file
OPTIONS (FILENAME '/app/hitvisc/main/hitvisc.conf', DELIMITER '=', FORMAT 'csv');

-- Создание представления для просмотра параметров без пробелов в названиях и значениях
CREATE VIEW registry.vw_system_parameter AS SELECT TRIM(name) AS name, TRIM(value) AS value FROM registry.system_parameter;

-- TODO: если потребуются такие файлы, то описать их в более конкретных таблицах
--
-- Файлы с настройками (к мишени или чему-либо ещё), добавляющиеся в рамках поиска
--CREATE TABLE registry.search_file
--(
--    id        INT NOT NULL,
--    search_id INT NOT NULL,
--    type      VARCHAR(16) NOT NULL,
--    name      VARCHAR(64) NOT NULL,
--    path      VARCHAR(256) NOT NULL
--);
--
--CREATE UNIQUE INDEX idx_search_file_pk ON registry.search_file(id);
--CREATE INDEX idx_search_file_research_fk ON registry.search_file(search_id);
--ALTER TABLE registry.search_file ADD CONSTRAINT cs_search_file_pk PRIMARY KEY USING INDEX idx_search_file_pk;
--ALTER TABLE registry.search_file ADD CONSTRAINT cs_search_file_research_fk FOREIGN KEY(search_id) REFERENCES registry.search(id);

--COMMENT ON TABLE registry.search_file IS 'Файл с настройками поиска';
--COMMENT ON COLUMN registry.search_file.search_id IS 'Идентификатор поиска';
--COMMENT ON COLUMN registry.search_file.type IS 'Вид файла';
--COMMENT ON COLUMN registry.search_file.name IS 'Название файла';
--COMMENT ON COLUMN registry.search_file.path IS 'Полный путь к файлу';

-- Последовательность для идентификации файлов мишени, добавляющихся в рамках поиска
--CREATE SEQUENCE registry.seq_search_file_id START WITH 1 INCREMENT BY 1 MINVALUE 1 NO MAXVALUE;
