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
    project_database = "";
    project_user = "";
    project_password = "";
    registry_database = "";

    get_completed_workunits_template = "echo \"SELECT name FROM workunit WHERE canonical_resultid > 0 AND '{BeginTime}' < mod_time AND mod_time <= '{EndTime}';\" | mysql --database={ProjectDatabase} --user={ProjectUser} --password={ProjectPassword} --silent --skip-column-names 2>/dev/null | tr '\\t' '|'";
    get_completed_workunits = "";
    get_error_workunits_template = "echo \"SELECT name FROM workunit WHERE error_mask != 0 AND assimilate_state = 2 AND '{BeginTime}' < mod_time AND mod_time <= '{EndTime}';\" | mysql --database={ProjectDatabase} --user={ProjectUser} --password={ProjectPassword} --silent --skip-column-names 2>/dev/null | tr '\\t' '|'";
    get_error_workunits = "";

    complete_workunit_template = "psql --dbname={RegistryDatabase} --command=\"UPDATE registry.workunit SET state_id = (SELECT id FROM registry.workunit_state WHERE name = 'COMPUTED') WHERE name = '{WorkunitName}' AND state_id = (SELECT id FROM registry.workunit_state WHERE name = 'IN_PROCESS') AND (SELECT status FROM registry.search WHERE id = registry.workunit.search_id) = 'A'\" &>/dev/null";
    complete_workunit_command = "";
    mark_error_workunit_template = "psql --dbname={RegistryDatabase} --command=\"UPDATE registry.workunit SET state_id = (SELECT id FROM registry.workunit_state WHERE name = 'ERROR') WHERE name = '{WorkunitName}' AND state_id = (SELECT id FROM registry.workunit_state WHERE name = 'IN_PROCESS')\" &>/dev/null";
    mark_error_workunit_command = "";

    get_new_checkpoint_time = "date \"+%Y-%m-%d %H:%M:%S\"";
    checkpoint_file = "checkpoint_wu.txt";
    old_checkpoint_time = "2023-01-01 00:00:00";
    new_checkpoint_time = "";
    workunits[0] = "";
    workunit_name = "";
    workunits_count = 0;

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
        project_database  = parameters["project_database"];
        project_user      = parameters["project_user"];
        project_password  = parameters["project_password"];
        registry_database = parameters["registry_database"];

        # Print read parameters
        #print("-----------------------------------------------------------------");
        #print("--- Starting workunits completion ---");
        #print("-----------------------------------------------------------------");
        #print("--- Run with the following parameters:");
        #print("project_database      = " project_database);
        #print("project_user          = " project_user);
        #print("project_password      = " project_password);
        #print("registry_database     = " registry_database);
        #print("-----------------------------------------------------------------");

    # Put parameters into commands and templates
    gsub("{ProjectDatabase}", project_database, get_completed_workunits_template);    
    gsub("{ProjectUser}", project_user, get_completed_workunits_template);
    gsub("{ProjectPassword}", project_password, get_completed_workunits_template);
    gsub("{RegistryDatabase}", registry_database, complete_workunit_template);

    # Get new checkpoint time
    get_new_checkpoint_time | getline new_checkpoint_time;
    close(get_new_checkpoint_time);

    # Sleep for 1 second
    system("sleep 1");

    # Print checkpoint info
    if ((getline old_checkpoint_time < checkpoint_file) > 0)
    {
        print("Previous checkpoint time: " old_checkpoint_time)
    }
    else
    {
        print("Use default value for checkpoint time: " old_checkpoint_time);
    }
    print("New checkpoint time: " new_checkpoint_time);
    close(checkpoint_file);

    ## Get completed workunits
        # Build command
        get_completed_workunits = get_completed_workunits_template;
        gsub("{BeginTime}", old_checkpoint_time, get_completed_workunits);
        gsub("{EndTime}", new_checkpoint_time, get_completed_workunits);

        # Read completed workunits
        while ((get_completed_workunits | getline workunit_name) > 0)
        {
            workunits[workunits_count] = workunit_name;
            workunits_count++;
        }
        close(get_completed_workunits);

    # Update status of completed workunits
    for (i = 0; i < workunits_count; i++)
    {
        complete_workunit_command = complete_workunit_template;
        gsub("{WorkunitName}", workunits[i], complete_workunit_command);
        system(complete_workunit_command);
        print("Completed workunit: " workunits[i]);
    }

    ## Get error workunits
        delete workunits;
        workunits[0] = "";
        workunit_name = "";
        workunits_count = 0;
        # Build command
        get_error_workunits = get_error_workunits_template;
        gsub("{BeginTime}", old_checkpoint_time, get_error_workunits);
        gsub("{EndTime}", new_checkpoint_time, get_error_workunits);

        # Read error workunits
        while ((get_error_workunits | getline workunit_name) > 0)
        {
            workunits[workunits_count] = workunit_name;
            workunits_count++;
        }
        close(get_error_workunits);

    # Update status of error workunits
    for (i = 0; i < workunits_count; i++)
    {
        mark_error_workunit_command = mark_error_workunit_template;
        gsub("{WorkunitName}", workunits[i], mark_error_workunit_command);
        system(mark_error_workunit_command);
        print("Marked workunit as error: " workunits[i]);
    }

    # Write new checkpoint into file
    print(new_checkpoint_time) > checkpoint_file;

    # Print exit message
    #print("-----------------------------------------------------------------");
    #print("--- End of workunits completion!");
    #print("-----------------------------------------------------------------");
}
