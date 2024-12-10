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

    # Commands and checkpoints
    get_new_hosts_template = "echo \"SELECT * FROM (SELECT id, userid, FROM_UNIXTIME(create_time) AS create_timestamp, venue FROM host) host_creation WHERE '{BeginTimestamp}' < create_timestamp AND create_timestamp <= '{EndTimestamp}';\" | mysql --database={ProjectDatabase} --user={ProjectUser} --password={ProjectPassword} --skip-column-names 2>/dev/null | tr '\\t' '|'";
    get_new_hosts_command = "";
    save_host_template = "psql --dbname={RegistryDatabase} --command=\"SELECT registry.boinc_host_add({BoincHostId}, {BoincUserId}, {ResourceType});\"";
    save_host_command = "";
    get_hosts_stat_template = "echo \"SELECT result.hostid AS host_id, host_rpc.last_request_time, COUNT(IF(result.granted_credit > 0, 1, NULL)) AS completed_results, COUNT(IF(result.granted_credit = 0, 1, NULL)) AS results_in_process FROM result JOIN (SELECT id, FROM_UNIXTIME(rpc_time) AS last_request_time FROM host) AS host_rpc ON host_rpc.id = result.hostid WHERE '{BeginTimestamp}' < result.mod_time AND result.mod_time <= '{EndTimestamp}' GROUP BY hostid;\" | mysql --database={ProjectDatabase} --user={ProjectUser} --password={ProjectPassword} --skip-column-names 2>/dev/null | tr '\\t' '|'";
    get_hosts_stat_command = "";
    update_host_stat_template = "psql --dbname={RegistryDatabase} --command=\"SELECT registry.boinc_host_update_stat({BoincHostId}, {LastRequestTime}, {TasksCompleted}, {TasksInProgress});\"";
    update_host_stat_command = "";

    get_new_checkpoint_time = "date \"+%Y-%m-%d %H:%M:%S\"";
    checkpoint_file = "checkpoint_host.txt";
    old_checkpoint_time = "2024-01-01 00:00:00";
    new_checkpoint_time = "";

    # Computers data
    host_row = 0;
    host_values[0] = "";
    hosts[0]["id"] = "";
    hosts_count = 0;
    i = 0;
    hosts_stat_count = 0;
    host_stat_row = "";
    host_stat_row_values[0] = "";
    host_stat_values[0]["host_id"] = "";


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
        #print("--- Starting host synchronization ---");
        #print("-----------------------------------------------------------------");
        # print("--- Run with the following parameters:");
        # print("project_database      = " project_database);
        # print("project_user          = " project_user);
        # print("project_password      = " project_password);
        # print("registry_database     = " registry_database);
        # print("-----------------------------------------------------------------");

    # Get new checkpoint time
    get_new_checkpoint_time | getline new_checkpoint_time;
    close(get_new_checkpoint_time);

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

    # Put parameters into templates (parameters with constant values during script execution, that we can write into templates!)
    gsub("{ProjectDatabase}", project_database, get_new_hosts_template);
    gsub("{ProjectUser}", project_user, get_new_hosts_template);
    gsub("{ProjectPassword}", project_password, get_new_hosts_template);
    gsub("{BeginTimestamp}", old_checkpoint_time, get_new_hosts_template);
    gsub("{EndTimestamp}", new_checkpoint_time, get_new_hosts_template);

    gsub("{RegistryDatabase}", registry_database, save_host_template);

    gsub("{ProjectDatabase}", project_database, get_hosts_stat_template);
    gsub("{ProjectUser}", project_user, get_hosts_stat_template);
    gsub("{ProjectPassword}", project_password, get_hosts_stat_template);
    gsub("{BeginTimestamp}", old_checkpoint_time, get_hosts_stat_template);
    gsub("{BeginTimestamp}", old_checkpoint_time, get_hosts_stat_template);
    gsub("{EndTimestamp}", new_checkpoint_time, get_hosts_stat_template);

    gsub("{RegistryDatabase}", registry_database, update_host_stat_template);


    # Read new hosts
    get_new_hosts_command = get_new_hosts_template;
    hosts_count = 0;
    while ((get_new_hosts_command | getline host_row) > 0)
    {
        split(host_row, host_values, "|");
        hosts[hosts_count]["id"] = host_values[1];
        hosts[hosts_count]["user_id"] = host_values[2];
        hosts[hosts_count]["create_time"] = host_values[3];
        hosts[hosts_count]["venue"] = host_values[4];
        print("Readed values: " hosts[hosts_count]["id"] " " hosts[hosts_count]["user_id"] " " hosts[hosts_count]["create_time"]);
        hosts_count++;
    }
    close(get_new_hosts_command);

    # Process new hosts: add HiTViSc host if a new BOINC host has been registered
    for (i = 0; i < hosts_count; i++)
    {
        save_host_command = save_host_template;
        gsub("{BoincHostId}", hosts[i]["id"], save_host_command);
        gsub("{BoincUserId}", hosts[i]["user_id"], save_host_command);

        resourceType = "'R'"; # Private by default
        if(hosts[i]["venue"] == "home")   { resourceType = "'R'"; }
        if(hosts[i]["venue"] == "work")   { resourceType = "'T'"; }
        if(hosts[i]["venue"] == "school") { resourceType = "'P'"; }
        gsub("{ResourceType}", resourceType, save_host_command);

        print("Try to add host with id = " hosts[i]["id"] " owned by user with id = " hosts[i]["user_id"]);
        system(save_host_command);
    }

    # Read hosts stats
    get_hosts_stat_command = get_hosts_stat_template;
    hosts_stat_count = 0;
    while ((get_hosts_stat_command | getline host_stat_row) > 0)
    {
        split(host_stat_row, host_stat_row_values, "|");
        host_stat_values[hosts_stat_count]["host_id"] = host_stat_row_values[1];
        host_stat_values[hosts_stat_count]["last_request_time"] = host_stat_row_values[2];
        host_stat_values[hosts_stat_count]["completed_results"] = host_stat_row_values[3];
        host_stat_values[hosts_stat_count]["results_in_process"] = host_stat_row_values[4];
        #host_stat_values[hosts_stat_count]["venue"] = host_stat_row_values[5];
        print("Read stats values: " host_stat_values[hosts_stat_count]["host_id"] " " host_stat_values[hosts_stat_count]["last_contact_time"] " " host_stat_values[hosts_stat_count]["completed_results"] " " host_stat_values[hosts_stat_count]["results_in_process"]);
        hosts_stat_count++;
    }

    # Update HiTViSc hosts stats: LastRequestTime, TasksCompleted, TasksInProgress
    for (i = 0; i < hosts_stat_count; i++)
    {
        update_host_stat_command = update_host_stat_template;
        gsub("{BoincHostId}", host_stat_values[i]["host_id"], update_host_stat_command);
        gsub("{LastRequestTime}", "'" host_stat_values[i]["last_request_time"] "'", update_host_stat_command);
        gsub("{TasksCompleted}", host_stat_values[i]["completed_results"], update_host_stat_command);
        gsub("{TasksInProgress}", host_stat_values[i]["results_in_process"], update_host_stat_command);
        #resourceType = "'P'";
        #if(host_stat_values[i]["venue"] == "home")   { resourceType = "'R'"; }
        #if(host_stat_values[i]["venue"] == "work")   { resourceType = "'T'"; }
        #if(host_stat_values[i]["venue"] == "school") { resourceType = "'P'"; }
        #gsub("{ResourceType}", resourceType, update_host_stat_command);
        #print("Try to update stats: " update_host_stat_command);
        system(update_host_stat_command);
    }

    # Write new checkpoint into file
    print(new_checkpoint_time) > checkpoint_file;

    # Sleep for 1 second
    system("sleep 1");

    # Print exit message
    #print("-----------------------------------------------------------------");
    #print("--- End of host synchronization!");
    #print("-----------------------------------------------------------------");
}
