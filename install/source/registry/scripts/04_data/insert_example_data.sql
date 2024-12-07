-- Вставка в таблицы набора тестовых данных: мишень для программ молекулярного докинга CmDock и AutoDock Vina,
-- справочный лиганд для нее, настройки докинга; тестовые библиотеки лигандов для CmDock и AutoDock Vina
DO
$$
DECLARE
	example_front_target_cmdock_id INTEGER;
	example_front_target_autodockvina_id INTEGER;
	example_back_target_cmdock_id INTEGER;
	example_back_target_autodockvina_id INTEGER;
	example_mapping_target INTEGER;
	example_refligand_cmdock_id INTEGER;
	example_refligand_autodockvina_id INTEGER;
	example_front_library_cmdock_id INTEGER;
	example_front_library_autodockvina_id INTEGER;
	example_back_library_cmdock_id INTEGER;
	example_back_library_autodockvina_id INTEGER;
	example_mapping_library INTEGER;
	example_docker_protocol_cmdock_id INTEGER;
	example_docker_protocol_autodockvina_id INTEGER;
	example_search_protocol_id INTEGER;
BEGIN
	TRUNCATE registry.example, registry.search_protocol, registry.docker_protocol_item, registry.docker_protocol, registry.package, registry.library, registry.reference_ligand_file, registry.reference_ligand, registry.target_file, registry.target CASCADE;

	--SELECT NEXTVAL('registry.front_target_id_seq') INTO example_front_target_cmdock_id;
        --SELECT NEXTVAL('registry.front_target_id_seq') INTO example_front_target_autodockvina_id;
	SELECT NEXTVAL('registry.seq_target_id') INTO example_back_target_cmdock_id;
	SELECT NEXTVAL('registry.seq_target_id') INTO example_back_target_autodockvina_id;
	SELECT NEXTVAL('registry.seq_reference_ligand_id') INTO example_refligand_cmdock_id;
	SELECT NEXTVAL('registry.seq_reference_ligand_id') INTO example_refligand_autodockvina_id;
	--SELECT NEXTVAL('registry.front_library_id_seq') INTO example_front_library_cmdock_id;
	--SELECT NEXTVAL('registry.front_library_id_seq') INTO example_front_library_autodockvina_id;
	SELECT NEXTVAL('registry.seq_library_id') INTO example_back_library_cmdock_id;
	SELECT NEXTVAL('registry.seq_library_id') INTO example_back_library_autodockvina_id;
	SELECT NEXTVAL('registry.seq_docker_protocol_id') INTO example_docker_protocol_cmdock_id;
	SELECT NEXTVAL('registry.seq_docker_protocol_id') INTO example_docker_protocol_autodockvina_id;
	SELECT NEXTVAL('registry.seq_search_protocol_id') INTO example_search_protocol_id;

	--INSERT INTO registry.front_target(id, name, description, authors, source, state, type_of_use, pdb_file_id, reference_ligands_file_id, created_by)
	--	VALUES(example_front_target_cmdock_id, 'Example target for CmDock', 'Example target', 'HiTViSc Administrator', 'HiTViSc example data', 'U'::registry.front_target_state_enum, 'O'::registry.front_target_type_of_use_enum, '', '', 0);
        --INSERT INTO registry.front_target(id, name, description, authors, source, state, type_of_use, pdb_file_id, reference_ligands_file_id, created_by)
        --        VALUES(example_front_target_autodockvina_id, 'Example target for AutoDock Vina', 'Example target', 'HiTViSc Administrator', 'HiTViSc example data', 'U'::registry.front_target_state_enum, 'O'::registry.front_target_type_of_use_enum, '', '', 0);

	INSERT INTO registry.target(id, create_time, name, system_name, description, authors, source, usage_type, state) 
		VALUES (example_back_target_cmdock_id, CURRENT_TIMESTAMP, 'Example target for CmDock', 'example_cmdock', 'Example target', 'HiTViSc Administrator', 'HiTViSc example data', 'O', 'U');
	INSERT INTO registry.target(id, create_time, name, system_name, description, authors, source, usage_type, state) 
		VALUES (example_back_target_autodockvina_id, CURRENT_TIMESTAMP, 'Example target for AutoDock Vina', 'example_autodockvina', 'Example target', 'HiTViSc Administrator', 'HiTViSc example data', 'O', 'U');
	--SELECT registry.hitvisc_entity_mapping_add(example_front_target_cmdock_id, example_back_target_cmdock_id, 'T') INTO example_mapping_target;
        --SELECT registry.hitvisc_entity_mapping_add(example_front_target_autodockvina_id, example_back_target_autodockvina_id, 'T') INTO example_mapping_target;


	INSERT INTO registry.target_file(id, target_id, type, file_path, file_name) 
		VALUES (NEXTVAL('registry.seq_target_file_id'), example_back_target_cmdock_id, 'mol2', '/app/hitvisc/data/hitvisc.target.cmdock.example.mol2', 'hitvisc.target.cmdock.example.mol2');
	INSERT INTO registry.target_file(id, target_id, type, file_path, file_name) 
		VALUES (NEXTVAL('registry.seq_target_file_id'), example_back_target_autodockvina_id, 'pdbqt', '/app/hitvisc/data/hitvisc.target.autodockvina.example.pdbqt', 'hitvisc.target.autodockvina.example.pdbqt');

	INSERT INTO registry.reference_ligand(id, target_id, name, center_x, center_y, center_z, chain) 
		VALUES(example_refligand_cmdock_id, example_back_target_cmdock_id, '3WL', -33.1626, -65.0742, 41.4343, 'A');
	INSERT INTO registry.reference_ligand(id, target_id, name, center_x, center_y, center_z, chain) 
		VALUES(example_refligand_autodockvina_id, example_back_target_autodockvina_id, '3WL', -7.45476, -40.4256, 10.6011, 'A');

	INSERT INTO registry.reference_ligand_file(id, reference_ligand_id, type, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_reference_ligand_file_id'), example_refligand_cmdock_id, 'sdf', '/app/hitvisc/data/hitvisc.target.cmdock.example.refligand.sdf', 'hitvisc.target.cmdock.example.refligand.sdf');
	INSERT INTO registry.reference_ligand_file(id, reference_ligand_id, type, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_reference_ligand_file_id'), example_refligand_autodockvina_id, 'pdbqt', '/app/hitvisc/data/hitvisc.target.autodockvina.example.refligand.pdbqt', 'hitvisc.target.autodockvina.example.refligand.pdbqt');

        --INSERT INTO registry.front_library(id, name, description, authors, source, type_of_use, state, file_id, created_by)
	--	VALUES(example_front_library_cmdock_id, 'Small example ligands library for CmDock', 'Small example library for CmDock, contains 20 ligands', 'HiTViSc Administrator', 'HiTViSc example data', 'O'::registry.front_library_type_of_use_enum, 'U'::registry.front_library_state_enum, '', 0);
        --INSERT INTO registry.front_library(id, name, description, authors, source, type_of_use, state, file_id, created_by)
        --        VALUES(example_front_library_autodockvina_id, 'Small example ligands library for AutoDock Vina', 'Small example library for AutoDock Vina, contains 20 ligands', 'HiTViSc Administrator', 'HiTViSc example data', 'O'::registry.front_library_type_of_use_enum, 'U'::registry.front_library_state_enum, '', 0);

        INSERT INTO registry.library(id, create_time, name, system_name, description, authors, source, usage_type, state) 
              VALUES(example_back_library_cmdock_id, CURRENT_TIMESTAMP, 'Small example ligands library for CmDock', 'example_small_ligands_cmdock', 'Small example library for CmDock, contains 20 ligands', 'HiTViSc Administrator', 'HiTViSc example data', 'O', 'U');
        INSERT INTO registry.library(id, create_time, name, system_name, description, authors, source, usage_type, state) 
              VALUES(example_back_library_autodockvina_id, CURRENT_TIMESTAMP, 'Small example ligands library for AutoDock Vina', 'example_small_ligands_autodockvina', 'Small example library for AutoDock Vina, contains 20 ligands', 'HiTViSc Administrator', 'HiTViSc example data', 'O', 'U');
        --SELECT registry.hitvisc_entity_mapping_add(example_front_library_cmdock_id, example_back_library_cmdock_id, 'L') INTO example_mapping_library;
        --SELECT registry.hitvisc_entity_mapping_add(example_front_library_autodockvina_id, example_back_library_autodockvina_id, 'L') INTO example_mapping_library;


      INSERT INTO registry.package(id, library_id, file_name, file_path, ligand_count)  
                      VALUES(NEXTVAL('registry.seq_package_id'), example_back_library_cmdock_id, 'hitvisc.ligands.cmdock.example_small_package_01.zip', 
                             '/app/hitvisc/data/hitvisc.ligands.cmdock.example_small/hitvisc.ligands.cmdock.example_small_package_01.zip', 2), 
                            (NEXTVAL('registry.seq_package_id'), example_back_library_cmdock_id, 'hitvisc.ligands.cmdock.example_small_package_02.zip', 
                             '/app/hitvisc/data/hitvisc.ligands.cmdock.example_small/hitvisc.ligands.cmdock.example_small_package_02.zip', 2);

      INSERT INTO registry.package(id, library_id, file_name, file_path, ligand_count)
                      VALUES(NEXTVAL('registry.seq_package_id'), example_back_library_autodockvina_id, 'hitvisc.ligands.autodockvina.example_small_package_01.zip', 
                             '/app/hitvisc/data/hitvisc.ligands.autodockvina.example_small/hitvisc.ligands.autodockvina.example_small_package_01.zip', 2),
                             (NEXTVAL('registry.seq_package_id'), example_back_library_autodockvina_id, 'hitvisc.ligands.autodockvina.example_small_package_02.zip', 
                             '/app/hitvisc/data/hitvisc.ligands.autodockvina.example_small/hitvisc.ligands.autodockvina.example_small_package_02.zip', 2);


        --SELECT NEXTVAL('registry.front_library_id_seq') INTO example_front_library_cmdock_id;
        --SELECT NEXTVAL('registry.front_library_id_seq') INTO example_front_library_autodockvina_id;
        SELECT NEXTVAL('registry.seq_library_id') INTO example_back_library_cmdock_id;
        SELECT NEXTVAL('registry.seq_library_id') INTO example_back_library_autodockvina_id;

        --INSERT INTO registry.front_library(id, name, description, authors, source, type_of_use, state, file_id, created_by)
        --        VALUES(example_front_library_cmdock_id, 'Medium example ligands library for CmDock', 'Medium example library for CmDock, contains 100 ligands', 'HiTViSc Administrator', 'HiTViSc example data', 'O'::registry.front_library_type_of_use_enum, 'U'::registry.front_library_state_enum, '', 0);
        --INSERT INTO registry.front_library(id, name, description, authors, source, type_of_use, state, file_id, created_by)
        --        VALUES(example_front_library_autodockvina_id, 'Medium example ligands library for AutoDock Vina', 'Medium example library for AutoDock Vina, contains 100 ligands', 'HiTViSc Administrator', 'HiTViSc example data', 'O'::registry.front_library_type_of_use_enum, 'U'::registry.front_library_state_enum, '', 0);

	INSERT INTO registry.library(id, create_time, name, system_name, description, authors, source, usage_type, state) 
		VALUES(example_back_library_cmdock_id, CURRENT_TIMESTAMP, 'Medium example ligands library for CmDock', 'example_100_ligands_cmdock', 'Medium example library for CmDock, contains 100 ligands', 'Administrator', 'HiTViSc example data', 'O', 'U');
	INSERT INTO registry.library(id, create_time, name, system_name, description, authors, source, usage_type, state) 
		VALUES(example_back_library_autodockvina_id, CURRENT_TIMESTAMP, 'Medium example ligands library for AutoDock Vina', 'example_100_ligands_autodockvina', 'Medium example library for AutoDock Vina, contains 100 ligands', 'Administrator', 'HiTViSc example data', 'O', 'U');
        --SELECT registry.hitvisc_entity_mapping_add(example_front_library_cmdock_id, example_back_library_cmdock_id, 'L') INTO example_mapping_library;
        --SELECT registry.hitvisc_entity_mapping_add(example_front_library_autodockvina_id, example_back_library_autodockvina_id, 'L') INTO example_mapping_library;

	FOR i IN 1..10 LOOP
		INSERT INTO registry.package(id, library_id, file_name, file_path, ligand_count) 
			VALUES(NEXTVAL('registry.seq_package_id'), example_back_library_cmdock_id, 'hitvisc.ligands.cmdock.example_100_package_'||lpad(to_char(i, 'FM99'), 2, '0')||'.zip', '/app/hitvisc/data/hitvisc.ligands.cmdock.example_100/hitvisc.ligands.cmdock.example_100_package_'||lpad(to_char(i, 'FM99'), 2, '0')||'.zip', 10);
	END LOOP;

	FOR i IN 1..10 LOOP
		INSERT INTO registry.package(id, library_id, file_name, file_path, ligand_count) 
			VALUES(NEXTVAL('registry.seq_package_id'), example_back_library_autodockvina_id, 'hitvisc.ligands.autodockvina.example_100_package_'||lpad(to_char(i, 'FM99'), 2, '0')||'.zip', '/app/hitvisc/data/hitvisc.ligands.autodockvina.example_100/hitvisc.ligands.autodockvina.example_100_package_'||lpad(to_char(i, 'FM99'), 2, '0')||'.zip', 10);
	END LOOP;

	INSERT INTO registry.docker_protocol(id, name, system_name, description) 
		VALUES(example_docker_protocol_cmdock_id, 'Example target: CmDock', 'example_cmdock_protocol', 'Parameters for example target, CmDock');
	INSERT INTO registry.docker_protocol(id, name, system_name, description) 
		VALUES(example_docker_protocol_autodockvina_id, 'Example target: AutoDock Vina', 'example_autodockvina_protocol', 'Parameters for example target, AutoDock Vina');


-- Order of the BOINC input files for CmDock:
-- 0. TemplateIn
-- 1. TemplateOut
-- 2. prm
-- 3. as
-- 4. ptc
-- 5. mol2 (target)
-- 6. ligands.zip

-- Order of the BOINC input files for AutoDock Vina:
-- 0. TemplateIn
-- 1. TemplateOut
-- 2. Configuration
-- 3. pdbqt (target)
-- 4. ligands.zip

	INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, type, order_number, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_docker_protocol_item_id'), example_docker_protocol_cmdock_id, 'cmdock', 'TemplateIn', 0, 'templates/cmdock_in', 'cmdock_in');
	INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, type, order_number, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_docker_protocol_item_id'), example_docker_protocol_cmdock_id, 'cmdock', 'TemplateOut', 1, 'templates/cmdock_out', 'cmdock_out');
	INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, type, order_number, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_docker_protocol_item_id'), example_docker_protocol_cmdock_id, 'cmdock', 'CmDockConfigPRM', 2, '/app/hitvisc/data/hitvisc.docker_protocol.cmdock.example.prm', 'hitvisc.docker_protocol.cmdock.example.prm');
	INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, type, order_number, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_docker_protocol_item_id'), example_docker_protocol_cmdock_id, 'cmdock', 'CmDockConfigAS', 3, '/app/hitvisc/data/hitvisc.docker_protocol.cmdock.example.as', 'hitvisc.docker_protocol.cmdock.example.as');
	INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, type, order_number, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_docker_protocol_item_id'), example_docker_protocol_cmdock_id, 'cmdock', 'CmDockConfigPTC', 4, '/app/hitvisc/data/hitvisc.docker_protocol.cmdock.example.ptc', 'hitvisc.docker_protocol.cmdock.example.ptc');

	INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, type, order_number, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_docker_protocol_item_id'), example_docker_protocol_autodockvina_id, 'autodockvina', 'TemplateIn', 0, 'templates/autodockvina_in', 'autodockvina_in');
	INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, type, order_number, file_path, file_name) 
		VALUES(NEXTVAL('registry.seq_docker_protocol_item_id'), example_docker_protocol_autodockvina_id, 'autodockvina', 'TemplateOut', 1, 'templates/autodockvina_out', 'autodockvina_out');
        INSERT INTO registry.docker_protocol_item(id, docker_protocol_id, docking_app, type, order_number, file_path, file_name)
                VALUES(NEXTVAL('registry.seq_docker_protocol_item_id'), example_docker_protocol_autodockvina_id, 'autodockvina', 'AutoDockVinaConfigTXT', 2, '/app/hitvisc/data/hitvisc.docker_protocol.autodockvina.example.txt', 'hitvisc.docker_protocol.autodockvina.example.txt');

	INSERT INTO registry.search_protocol(id, hit_criterion, stop_criterion, hit_threshold_energy, stop_fraction_ligands, is_notify_hits, is_notify_fraction_ligands, value_notify_fraction_ligands) VALUES(example_search_protocol_id, 'N', 'L', -5.0, 1.0, TRUE, TRUE, 0.5);

	INSERT INTO registry.example(id, name, is_ready, target_id, library_id, docker_id, docker_protocol_id, search_protocol_id, host_usage_type) 
		VALUES(NEXTVAL('registry.seq_example_id'), 'Example with CmDock', TRUE, example_back_target_cmdock_id, example_back_library_cmdock_id, 1, example_docker_protocol_cmdock_id, example_search_protocol_id, 'T');
	INSERT INTO registry.example(id, name, is_ready, target_id, library_id, docker_id, docker_protocol_id, search_protocol_id, host_usage_type) 
		VALUES(NEXTVAL('registry.seq_example_id'), 'Example with AutoDock Vina', TRUE, example_back_target_autodockvina_id, example_back_library_autodockvina_id, 2, example_docker_protocol_autodockvina_id, example_search_protocol_id, 'T');

END;
$$;
   
