BEGIN {
    # Parameters variables
    #config_file = "hitvisc.conf";
    parameters[0] = "";
    parameter_line = "";
    name_value_pair[0] = "";
    parameter_name = "";
    parameter_value = "";

    # Connection attributes
    #project_host = "";
    project_directory = "";
    project_database = "";
    project_user = "";
    project_password = "";
    registry_database = "";

    # Commands templates and actual texts
    #chdir_boinc_project_command = "cd {ProjectDirectory}";
    get_active_searches_command = "psql --tuples-only --no-align --dbname={RegistryDatabase} \
                                   --command=\"SELECT id, prefix, docker_protocol_id \
                                   FROM registry.search \
                                   WHERE state = 'U' AND status = 'A'\"";
    get_docker_protocol_template = "psql --tuples-only --no-align --dbname={RegistryDatabase} \
                                    --command=\"SELECT id, docker_protocol_id, docking_app, type, \
                                    order_number, file_path, file_name \
                                    FROM registry.docker_protocol_item \
                                    WHERE docker_protocol_id = {ParameterSetId} \
                                    ORDER BY order_number\"";
    get_docker_protocol_command = "";

    # BOINC result.server_state == 2 for the state "Unsent".
    get_search_queue_template = "echo \"SELECT COUNT(*) FROM result \
                                 WHERE server_state = 2 AND name LIKE '{SearchPrefix}%';\" | \
                                 mysql --database={ProjectDatabase} --user={ProjectUser} \
                                 --password={ProjectPassword} --skip-column-names 2>/dev/null | tr '\\t' '|'";
    get_search_queue_command = "";

    get_generated_workunits_template = "psql --tuples-only --no-align --dbname={RegistryDatabase} \
                                        --command=\"SELECT workunit_id, workunit_name, target_file_name, \
                                        target_file_path, package_file_name, package_file_path, \
                                        application_system_name, application_version, resource_type \
                                        FROM registry.vw_workunit_to_generate \
                                        WHERE search_id = {SearchId} \
                                        ORDER BY workunit_id LIMIT {BatchSize}\"";
    get_generated_workunits_command = "";
    create_boinc_workunit_template = "cd {ProjectDirectory} && \
                                      ./bin/create_work {Application} {WuTemplate} {ResultTemplate} \
                                      {WorkunitName} {Parameters} {TargetFileName} {PackageFileName} &>/dev/null";
    create_boinc_workunit_command = "";
    update_workunit_state_template = "psql --dbname={RegistryDatabase} \
                                      --command=\"UPDATE registry.workunit \
                                      SET state_id = (SELECT id FROM registry.workunit_state \
                                      WHERE name = 'IN_PROCESS') WHERE id = {WorkunitId}\" &>/dev/null";
    update_workunit_state_command = "";
    stage_file_command_template = "cd {ProjectDirectory} && ./bin/stage_file --copy {FileName}";
    stage_file_command = "";

    # Variables for reading data about active searches and workunits
    searches[0][0] = "";                     # Array for data about created workunits
    searches_count = 0;                      # Number of active searches
    search_row = "";                         # Row with data about search from HiTViSc database
    search_row_values[0] = "";               # Separated fields from row with search data
    docker_protocol_item_row = "";           # Row with data about separate parameter set item
    docker_protocol_item_row_values[0] = ""; # Separated fields from row with parameter set data
    docker_protocol_items[0][0] = "";        # Arrary for data about files used in docking
    docker_protocol_items_count = 0;         # Number of parametes of search
    queue_size = "";                         # Search tasks queue size
    queue_threshold = 1;                     # Thresold queue length for beginning generation of new tasks
    workunits_batch_size = 12;               # Size of workunits batch for tasks generation
    workunit_row = "";                       # Row with data about workunit from HiTViSc database
    workunit_row_values[0] = "";             # Separated fields from row with workunits data
    workunits_to_create[0][0] = "";          # Array for data about created workunits
    workunits_count = 0;                     # Number of created workunits
    workunit_id = 0;                         # Counter for workunits processing
    workunit_parameters = "";                # File name parameters for workunit creation
    i = 0;                                   # Loop counter

    # Parameters reading
        # Read data from parameters file
        while ((getline parameter_line < config_file) > 0)
        {
            # Reading and parsing next line
            split(parameter_line, name_value_pair, "=");
            parameter_name = name_value_pair[1];
            parameter_value = name_value_pair[2];
            gsub(" ", "", parameter_name);
            gsub(" ", "", parameter_value);
            parameters[parameter_name] = parameter_value;
        }
        close(config_file);

        # Store read parameters into variables
        project_directory = parameters["project_directory"];
        project_database  = parameters["project_database"];
        project_user      = parameters["project_user"];
        project_password  = parameters["project_password"];
        registry_database = parameters["registry_database"];

        # Print read parameters
        #print("-------------------------------------------");
        #print("--- Starting BOINC workunits generation ---");
        #print("-------------------------------------------");
        #print("--- Run with the following parameters:");
        #print("project_directory     = " project_directory);
        #print("project_database      = " project_database);
        #print("project_user          = " project_user);
        #print("project_password      = " project_password);
        #print("registry_database     = " registry_database);
        #print("-------------------------------------");

    # Put parameters into commands and templates
    #gsub("{ProjectDirectory}", project_directory, chdir_boinc_project_command);
    gsub("{ProjectDirectory}", project_directory, create_boinc_workunit_template);
    gsub("{ProjectDirectory}", project_directory, stage_file_command_template);
    gsub("{ProjectDatabase}", project_database, get_search_queue_template);
    gsub("{ProjectUser}", project_user, get_search_queue_template);
    gsub("{ProjectPassword}", project_password, get_search_queue_template);
    gsub("{RegistryDatabase}", registry_database, get_active_searches_command);
    gsub("{RegistryDatabase}", registry_database, get_docker_protocol_template);
    gsub("{RegistryDatabase}", registry_database, get_generated_workunits_template);
    gsub("{RegistryDatabase}", registry_database, update_workunit_state_template);

    # Read prefixes of active searches
    while ((get_active_searches_command | getline search_row) > 0)
    {
        split(search_row, search_row_values, "|");
        searches[searches_count]["id"] = search_row_values[1];
        searches[searches_count]["prefix"] = search_row_values[2];
        searches[searches_count]["docker_protocol_id"] = search_row_values[3];
        searches_count++;
    }
    close(get_active_searches_command);
    #print("Active searches: " searches_count);

    # Read queue size of each active search
    for (i = 0; i < searches_count; i++)
    {
        get_search_queue_command = get_search_queue_template;
        gsub("{SearchPrefix}", searches[i]["prefix"], get_search_queue_command);
        get_search_queue_command | getline queue_size;
        close(get_search_queue_command);

        searches[i]["queue"] = 0 + queue_size
        #print("Queue size for search with id = " searches[i]["id"] " and prefix " searches[i]["prefix"] \
        #      " and docker_protocol_id " searches[i]["docker_protocol_id"] ": " searches[i]["queue"]);
    }

    # Form tasks for queues if needed
    for (i = 0; i < searches_count; i++)
    {
        # Create tasks for next search if needed
        if (searches[i]["queue"] <= queue_threshold)
        {
            # Create tasks for search
                # Read data about search parameters for next search
                get_docker_protocol_command = get_docker_protocol_template;
                gsub("{ParameterSetId}", searches[i]["docker_protocol_id"], get_docker_protocol_command);
                docker_protocol_items_count = 0;
                delete docker_protocol_items;

                # For each row returned by get_docker_protocol_command,
                # docker_protocol_item_row_values[] will contain values of the fields: 
                # 1 - id, 2 - docker_protocol_id, 3 - docking_app, 4 - type, 
                # 5 - order_number, 6 - file_path, 7 - file_name
                
                while ((get_docker_protocol_command | getline docker_protocol_item_row) > 0)
                {
                    # Read and store data about next search parameter
                        # Break line with data to separate values
                        split(docker_protocol_item_row, docker_protocol_item_row_values, "|");

                        # Process parameters
                            # Save template parameters into search attributes
                            if (docker_protocol_item_row_values[4] == "TemplateIn")
                            {
                                searches[i]["wu_template"] = docker_protocol_item_row_values[6];
                            }
                            if (docker_protocol_item_row_values[4] == "TemplateOut")
                            {
                                searches[i]["result_template"] = docker_protocol_item_row_values[6];
                            }
                          
                            # TODO: Parse docking app-dependent parameters 
                            #if(docker_protocol_item_row_values[3] == "cmdock")
                            #{
                            #
                            #
                            #} else
                            #{
                            #  if (docker_protocol_item_row_values[3] == "autodockvina")
                            #  {
                            #
                            #  }
                            #}

                            # For the parameters containing files, prepare files for BOINC staging
                            if (docker_protocol_item_row_values[4] == "CmDockConfigPRM" || 
                                docker_protocol_item_row_values[4] == "CmDockConfigAS" || 
                                docker_protocol_item_row_values[4] == "CmDockConfigPTC" || 
                                docker_protocol_item_row_values[4] == "AutoDockVinaConfigTXT")
                                {
                                    docker_protocol_items[docker_protocol_items_count]["file_path"] = docker_protocol_item_row_values[6];
                                    docker_protocol_items[docker_protocol_items_count]["file_name"] = docker_protocol_item_row_values[7];
                                    docker_protocol_items_count++;
                                }
                }
                close(get_docker_protocol_command);

                # Store parameters count into search description array
                searches[i]["parameters_count"] = docker_protocol_items_count;

                # Adding tasks for search
                    # Forms the command skeleton without workunit name

                    get_generated_workunits_command = get_generated_workunits_template;
                    gsub("{SearchId}", searches[i]["id"], get_generated_workunits_command);
                    gsub("{BatchSize}", workunits_batch_size, get_generated_workunits_command);
                    # print(get_generated_workunits_command);

                    # Reads the list of generated workunits with attributes
                    workunits_count = 0;
                    delete workunits_to_create;
                    while (get_generated_workunits_command | getline workunit_row)
                    {
                        split(workunit_row, workunit_row_values, "|");
                        workunits_to_create[workunits_count]["workunit_id"] = workunit_row_values[1];
                        workunits_to_create[workunits_count]["workunit_name"] = workunit_row_values[2];
                        workunits_to_create[workunits_count]["target_file_name"] = workunit_row_values[3];
                        workunits_to_create[workunits_count]["target_file_path"] = workunit_row_values[4];
                        workunits_to_create[workunits_count]["package_file_name"] = workunit_row_values[5];
                        workunits_to_create[workunits_count]["package_file_path"] = workunit_row_values[6];
                        workunits_to_create[workunits_count]["application_system_name"] = workunit_row_values[7];
                        workunits_to_create[workunits_count]["application_version"] = workunit_row_values[8];
                        workunits_to_create[workunits_count]["resource_type"] = workunit_row_values[9];
                        workunits_count++;
                    }
                    close(get_generated_workunits_command);

                    if(workunits_count > 0) 
                    {
                        print("Will generate " workunits_count " workunits for search: {" searches[i]["id"] ", " searches[i]["prefix"] ", queue = " searches[i]["queue"] ", parameters_count = " searches[i]["parameters_count"] "}");
                    }

                    # Perform stage all files that needed
                        # Perform staging of configuration files (using full paths to files)
                        for (j = 0; j < searches[i]["parameters_count"]; j++)
                        {
                            stage_file_command = stage_file_command_template;
                            gsub("{FileName}", docker_protocol_items[j]["file_path"], stage_file_command);
                            system(stage_file_command);
                        }

                        # Perform staging of target files (using full paths to files)
                        for (j = 0; j < workunits_count; j++)
                        {
                            stage_file_command = stage_file_command_template;
                            gsub("{FileName}", workunits_to_create[j]["target_file_path"], stage_file_command);
                            system(stage_file_command);
                        }

                        # Perform staging of packages (using full paths to files)
                        for (j = 0; j < workunits_count; j++)
                        {
                            stage_file_command = stage_file_command_template;
                            gsub("{FileName}", workunits_to_create[j]["package_file_path"], stage_file_command);
                            system(stage_file_command);
                        }

                    # Construct the line with workunit parameters
                    workunit_parameters = "";
                    for (k = 0; k < searches[i]["parameters_count"]; k++)
                    {
                        workunit_parameters = workunit_parameters " " docker_protocol_items[k]["file_name"];
                    }

                    # Invoke the command for workunit creation
                    for (j = 0; j < workunits_count; j++)
                    {
                        # Generate next workunit
                            # Create task inside BOINC server
                            create_boinc_workunit_command = create_boinc_workunit_template;
                            resource_type = workunits_to_create[j]["resource_type"];
                            appname = workunits_to_create[j]["application_system_name"];

                            if(appname == "" || resource_type == "") { print("Invalid appname or resource_type");  break; }
                            boinc_app_name = ""

                            if(appname == "cmdock") {
                                if(resource_type == "T") boinc_app_name = "test-cmdock";
                                if(resource_type == "R") boinc_app_name = "private-cmdock";
                                if(resource_type == "P") boinc_app_name = "public-cmdock";
                            }
                            if(appname == "autodockvina") {
                                if(resource_type == "T") boinc_app_name = "test-autodockvina";
                                if(resource_type == "R") boinc_app_name = "private-autodockvina";
                                if(resource_type == "P") boinc_app_name = "public-autodockvina";
                            }

                            if(boinc_app_name == "") { print("Could not get BOINC app name for appname", appname, "and resource type", resource_type); break; }

                            gsub("{Application}", "--appname " boinc_app_name, create_boinc_workunit_command);
                            #gsub("{Application}", "--appname " workunits_to_create[j]["application_system_name"], create_boinc_workunit_command);
                            gsub("{WuTemplate}", "--wu_template " searches[i]["wu_template"], create_boinc_workunit_command);
                            gsub("{ResultTemplate}", "--result_template " searches[i]["result_template"], create_boinc_workunit_command);
                            gsub("{WorkunitName}", "--wu_name " workunits_to_create[j]["workunit_name"], create_boinc_workunit_command);
                            gsub("{Parameters}", workunit_parameters, create_boinc_workunit_command);
                            gsub("{TargetFileName}", workunits_to_create[j]["target_file_name"], create_boinc_workunit_command);
                            gsub("{PackageFileName}", workunits_to_create[j]["package_file_name"], create_boinc_workunit_command);
 
                            #print("Will generate BOINC workunit: ");
                            #print(create_boinc_workunit_command);

                            system(create_boinc_workunit_command);

                            # Update workunit state into HiTViSc registry database
                            update_workunit_state_command = update_workunit_state_template;
                            gsub("{WorkunitId}", workunits_to_create[j]["workunit_id"], update_workunit_state_command);
                            # print(update_workunit_state_command);
                            system(update_workunit_state_command);
                    }
        }
    }

    # Print exit message
    #print("-------------------------------------");
    #print("--- End of BOINC tasks generation ---");
    #print("-------------------------------------");
}
