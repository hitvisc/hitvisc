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

    MAX_WORKUNITS_FOR_SEARCH = 100;

    # Commands templates and actual texts
    #chdir_boinc_project_command = "cd {ProjectDirectory}";
    get_active_searches_command = "psql --tuples-only --no-align --dbname={RegistryDatabase} \
                                   --command=\"SELECT id, prefix, docker_protocol_id \
                                   FROM registry.search WHERE state = 'U' AND status = 'A'\"";

    get_missing_packages_template = "psql --tuples-only --no-align --dbname={RegistryDatabase} \
                                     --command=\"SELECT p.id FROM registry.search \
                                     JOIN registry.library l ON registry.search.library_id = l.id \
                                     JOIN registry.package p ON l.id = p.library_id \
                                     JOIN registry.docker_version dv ON registry.search.docker_id = dv.docker_id AND dv.docker_id = p.docker_id \
                                     LEFT JOIN registry.workunit w ON w.search_id = registry.search.id AND w.package_id = p.id \
                                     WHERE w.id IS NULL AND registry.search.id = {SearchId} \
                                     ORDER BY p.id ASC\"";

    get_missing_packages_command = "";  

    create_hitvisc_workunits_template = "psql --tuples-only --no-align --dbname={RegistryDatabase} \
                                        --command=\"SELECT registry.create_workunits({SearchId}, \
                                        {FirstPackageId}, {LastPackageId});\" &>/dev/null"; 
    create_hitvisc_workunits_command = "";

    # Variables for reading data about active searches and workunits
    searches[0][0] = "";                     # Array for data about created workunits
    searches_count = 0;                      # Number of active searches
    search_row = "";                         # Row with data about search from HiTViSc database
    search_row_values[0] = "";               # Separated fields from row with search data
    workunits_count = 0;                     # Number of created workunits
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
        #print("---------------------------------------------");
        #print("--- Starting HiTViSc workunits generation ---");
        #print("---------------------------------------------");
        #print("--- Run with the following parameters:");
        #print("project_directory     = " project_directory);
        #print("project_database      = " project_database);
        #print("project_user          = " project_user);
        #print("project_password      = " project_password);
        #print("registry_database     = " registry_database);
        #print("-------------------------------------");

    # Put parameters into commands and templates
    gsub("{RegistryDatabase}", registry_database, get_active_searches_command);
    gsub("{RegistryDatabase}", registry_database, get_missing_packages_template);
    gsub("{RegistryDatabase}", registry_database, create_hitvisc_workunits_template);

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
    print("Active searches: " searches_count);

    # Form tasks for queues if needed
    for (i = 0; i < searches_count; i++)
    {
        # Get existing workunits for this search
        get_missing_packages_command = get_missing_packages_template;
        gsub("{SearchId}", searches[i]["id"], get_missing_packages_command);
        workunits_created = 0;
        while ((get_missing_packages_command | getline package_id) && workunits_created < MAX_WORKUNITS_FOR_SEARCH)
        {
            #print("Missing package: ", package_id, " in search ", searches[i]["id"]);            

            # Create a workunit for the missing package
            create_hitvisc_workunits_command = create_hitvisc_workunits_template;
            gsub("{SearchId}", searches[i]["id"], create_hitvisc_workunits_command);
            gsub("{FirstPackageId}", package_id, create_hitvisc_workunits_command);
            gsub("{LastPackageId}", package_id, create_hitvisc_workunits_command);
            system(create_hitvisc_workunits_command);
            workunits_created++;
        }
        close(get_missing_packages_command);
    }

    # Print exit message
    #print("-------------------------------------------");
    #print("--- End of HiTViSc workunits generation ---");
    #print("-------------------------------------------");
}
