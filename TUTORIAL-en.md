## System installation

_Working computer_ is the computer of the system administrator, from which the preliminary configuration of the HiTViSc system is performed and commands for deploying the system to the remote server are sent. _Remote server_ is the computer on which the HiTViSc system will be directly deployed, including all its components, databases and the end user web interface.

1. Download the source code and prepare the _working computer_:

```
# Make sure that we are in the working directory, for example, /home/user/work
git clone https://github.com/hitvisc/hitvisc.git
cd hitvisc/install
ssh-keygen -t ed25519 #(press Enter 3 times to choose the default directory for SSH keys and an empty password)
cat ~/.ssh/id_ed25519 > keys/ansible.key
chmod 600 keys/ansible.key
cat ~/.ssh/id_ed25519.pub #(copy the public key contents for step 2)
sudo apt-get update && sudo apt install ansible
```

2. Prepare the _remote server_ for work. Let's assume that the administrator account (root) is accessible via ssh at the IP address [IP address] with password ansibleRootPasswd. During the installation process, there will be created a user account named ansible, with password ansiblePasswd, on the server.

```
ssh root@[IP address] #(enter root's password - ansibleRootPasswd)
useradd -m --shell /bin/bash ansible && usermod -a -G sudo ansible && echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && apt-get update && apt install -y git vim 
passwd ansible #(enter the password for the created user - ansiblePasswd)
hostname #(the printed host name will be used to setup the parameters on the working computer at step 3)

su ansible
mkdir -p ~/.ssh
vim ~/.ssh/authorized_keys #(insert, from a new line, the public key contents copied at step 1)
```

3. Set up access settings to the remote server on your _working computer_:

```
# Make sure that we are in the working directory, for example, /home/user/work
cd hitvisc/install
cp group_vars/TargetServers.example group_vars/TargetServers
vim group_vars/TargetServers #(setup in file group_vars/TargetServers actual parameters of boinc_project_host, boinc_url_base and boinc_db_host, using the host name and external IP of the remote server [IP address])
cp source/hitvisc/main/hitvisc.conf.example source/hitvisc/main/hitvisc.conf 
vim inventory.txt #(setup in file inventory.txt the host name and external IP of the remote server [IP address])
```

If you wish, you can set your own parameter values ​​in the group_vars/TargetServers and source/hitvisc/main/hitvisc.conf files.

You can choose the settings associated with the BOINC project running inside the HiTViSc system at your own discretion. They set the parameters for accessing the BOINC project and are specified in the group_vars/TargetServers file. The couple of parameters boinc_url_base and boinc_project_name defines a unique, unchangeable URL for the BOINC project. The boinc_project_caption parameter defines the project name displayed in the BOINC client. If you plan to involve a wide range of volunteers in the computations, it is recommended to think about the project name and URL address in advance.

>boinc_project_host           : [REPLACE WITH YOUR SERVER HOSTNAME]  
>boinc_url_base               : http://[REPLACE WITH YOUR SERVER IP ADDRESS]/  
>boinc_project_home           : hitboinc  
>boinc_db_host                : [REPLACE WITH YOUR SERVER HOSTNAME]  
>boinc_db_name                : hitboinc  
>boinc_db_user                : hitviscadm  
>boinc_db_password            : hitviscadmPasswd  
>boinc_project_name           : hitboinc  
>boinc_project_caption        : HiTViSc@home  

4. Install the back-end on a remote server.

The deployment of the back-end part of the System is provided by Ansible scripts, which perform all the necessary actions to install and configure the system software. Sequential execution of scripts allows you to install the system environment step by step with the ability to adjust, if necessary, in case of errors.

To install the back-end, the following set of commands is executed on the _working computer_:

```
# Make sure that we are in the working directory, for example, /home/user/work
cd hitvisc/install
ansible-playbook -K hitvisc-install.yml && ansible-playbook -K postgresql-install.yml \
 && ansible-playbook -K hitvisc-main-install.yml && ansible-playbook -K boinc-install.yml \
 && ansible-playbook -K hitvisc-boinc-install.yml && ansible-playbook -K registry-install.yml \
 && ansible-playbook -K third-party-install.yml && ansible-playbook -K frontend-install.yml
```

As a result of successful execution of the commands, all necessary system directories will be created in the directory tree ``/app/*``, and the necessary tables in the database will be created and filled with a basic set of data.

5. Install the front-end settings on the _remote server_.

```
vim /app/hitvisc/front/pm2.production.config.js #(setup actual parameters)
```

In the settings file ``/app/hitvisc/front/pm2.production.config.js``, the following group of parameters sets the rules for accessing the e-mail account that will be used in the system to confirm user registrations/password recovery:

>EMAIL_HOST: "smtp.yandex.ru", (must be replaced with the SMTP server host of the mail account)
>EMAIL_PORT: 465, (must be replaced with the port number of the mail account)
>EMAIL_USER: "user@yandex.ru", (must be replaced with the e-mail address of the mail account)
>EMAIL_PASSWORD: "apppassword", (must be replaced with the password of the mail account application)


6. Complete the System preparation on the _working computer_.

```
# Make sure that we are in the working directory, for example, /home/user/work
cd hitvisc/install
ansible-playbook hitvisc-finalize.yml
```

After successful installation of the back-end and front-end parts of the System, the user web interface of the System is accessible from a web browser at an address of the form http://ADDRESS:PORT, in which the substring ADDRESS is specified on the _working computer_ in the file install/inventory.txt in the variable

```
ansible_host=<ip address of the remote server>
```

and the PORT substring is specified on the _remote server_ in the /app/hitvisc/front/pm2.production.config.js file in the variable

```
PORT: <web port number>
```
(8080 by default). Web interface provides the ability to register a new account as well as login using a predefined account (adm.hitvisc@yandex.ru, password).

> [!IMPORTANT]
> For the system to work, you must allow incoming TCP traffic to ports 8080 and 9090.

## General system interface

The general user interface of the system consists of a menu bar (left side) and a screen workspace implementing the main system-user interactions.
The menu bar consists of the following sections:
- Projects – a list of the user's projects, and functions for creating new projects,
- Resources – a list of the user's computing resources, including test, public, and private ones,
- News – information about important system events such as software updates, creation and completion of publicly available projects,
- Library:
    - Targets – a library of available targets,
    - Ligands – a library of available ligands,
- Notifications – User notifications about events in projects, such as completing a certain number of tasks or discovering a certain number of hits in the user's projects,
- Settings – system settings related to interaction with the user.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_overview.png)

The main functionality of the system is related to the creation of virtual screening projects. Available for users:
- Projects creation,
- Projects editing,
- Use of the project results.

## Projects creation

To create a project, use the "Add" button in the "Projects" section.
![image](https://github.com/hitvisc/hitvisc/blob/main/img/add_project.png)

When you click on the button, a New Project Creation Assistant form appears. The assistant implements four stages for creating a project with the necessary parameters.
At each step, the user has the opportunity to verify the completed data by clicking the "Next" button or proceed to the next step without verification.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_project_step1.png)

The first step in creating a project is to describe it, specify a target and a library of ligands. The user inputs the project name, access mode, and description.
There are three access modes for the project:
- Closed – the project is not published in the system for other users; 
- Private – only general information about the project is available to users of the system;
- General – the project is available for review by all users of the system, including the initial data, the parameters of the experiment, and its results.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_project_step1_fields.png)

The target is selected from the target library, and the ligand library is selected from the corresponding library. To learn more about the functionality of creating, editing, and deleting a library of targets, go to the instructions section "Library Management".
In the next step, you need to select the calculation application and set the parameters (protocol) of molecular docking in accordance with the selected application. Two of the most widely used molecular docking programs are available in the system – AutoDock Vina and CmDock. The settings of the molecular docking protocol can either be entered manually or downloaded with the appropriate file.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_project_step2_advina.png)

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_project_step2_cmdock.png)

The next stage of creating a project is to set the experiment parameters. At this step, hit selection criteria are set (binding energy or ligand efficiency), a stop criterion (percentage of tested ligands, number of hits found, or percentage of hits from the number of ligands), and user alerts are set.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_project_step3.png)

At this stage the user also selects computing resources that will be used when launching the project. The user can choose from the following types of resources:
- Test resources – highly reliable and affordable computing resources, provided by the system and used in a limited mode to test project settings;
- Private resources – resources added by the user from his own available ones;
- Publicly available resources – resources of other users of the system, marked as publicly available, resources of volunteers.

The final step of creating a project is to launch it. At this step, the user is provided with a summary of all project parameters and is asked to send the project to run computations

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_project_step4.png)

As a result of completing all the steps of the Assistant, upon successful verification, a project will be created using available computing resources. The virtual screening procedure is computationally intensive, so it can take from several hours to several months, depending on the set parameters, the size of the ligand library used, and the amount of computing resources available.

## Editing and deleting projects

A previously created saved project can be edited and/or deleted. To do this, select "Edit project" or "Delete project" in the system interface, in the main window of the project list, on the corresponding project card. Editing is only available for projects owned by this user and with the status "ready". You can edit the name, type of use and description. The functionality of editing a project is similar to the functionality of creating a project in Step 1 with previously filled in fields. Deletion is only available for projects owned by this user. When deleting, the project is transferred to the "archived" status.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_search_edit.png)

## Use of project results

To access the project results in the system interface, in the main window of the project list, on the corresponding project card, click the "Results" button.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_project_card.png)


The results are available as three files: a file with information about all hits, a file with a table of chemically diverse hits, and a visualization file of multiple hits.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_project_results.png)

## Resource management

Resources are computing nodes (personal computers or workstations, servers, computing clusters) used to perform calculations (modeling, molecular docking) for virtual screening. To solve the general problem of virtual screening, the complete database of ligands is divided into parts, forming tasks for a computing node, within which it performs molecular docking of a small number of ligands against the` target.
There are three types of resources allocated in the system:
- Test resources – highly reliable and affordable computing resources, provided by the system and used in a limited mode to test project settings,
- Private resources – resources added by the user from his own available ones;
- Publicly available resources – resources of other users of the system, marked as publicly available, resources of volunteers.
To manage resources, select the appropriate section in the menu bar.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_menu_resources.png)

### Shared resources

When you select the "Resources-Shared" menu item, a list of available system shares is displayed in the work window.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_resources_overview.png)

The following information is displayed in the list of shared system resources:
- name of the computing node,
- the date of the last request of the computing node to the system server (received task or report on the results),
- the number of current tasks that were previously sent to the computing node and for which results have not yet been received,
- the total number of tasks completed by the node,
- the computing node access mode.
For computing nodes added by the user, the node name and type can be edited.

### Private resources

When you select the "Resources-Private" menu item, a list of available private system resources is displayed in the work window.
The following information is displayed in the list of private resources of the system:
- name of the computing node,
- the date of the last request of the computing node to the system server (received task or report on the results),
- the number of current tasks that were previously sent to the computing node and for which results have not yet been received,
- the total number of tasks completed by the node,
- the computing node access mode.
For computing nodes added by the user, the node name and type can be edited.

### Test resources

When you select the "Resources-Test" menu item, a list of available shared system resources is displayed in the work window.
The following information is displayed in the list of test system resources:
- name of the computing node,
- the date of the last request of the computing node to the system server (received task or report on the results),
- the number of current tasks that were previously sent to the computing node and for which results have not yet been received,
- the total number of tasks completed by the node,
- the computing node access mode.
For computing nodes added by the user, the node name can be edited. The type of a test resource cannot be changed.

### Adding resources

The addition of computing nodes is available. A new computing node is added with type "private". If needed, the type of the node can be changed on page "Resources-Private".
When you click the "Add" button in the corresponding resource section, a pop-up window provides instructions on how to connect a new computing node.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_node_add.png)

Only the computing node on which the corresponding software is installed, the BOINC client, can be connected. The connection of the computing node is performed using standard BOINC client tools.

## Library management

Libraries are used to structure, store, and reuse information about targets and ligands used in virtual screening projects.
The appropriate library section is selected via the side menu.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_menu_library.png)

### Targets

When you select the "Target Library" section of the side menu, a list of available target libraries is displayed in the work window.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_targets.png)

Target libraries are displayed as flashcards. Each card contains the following information:
- Access mode,
- The author or the authors,
- The creator (the user who added the library),
- A short description.
  
Editing and deleting libraries are available for libraries created by the user.
To add a new target library, click the "Add" button of the main work window and fill out the appropriate form.
When filling out the form, you must specify the following information:
- The name of the target library,
- Brief description of the target library,
- Authorship of the library,
- The source from which the library was obtained,
- Library access mode (closed, private, shared),
- The source of the target file in PDB format which can be a separate PDB file or the PDB file ID in the target database.
- The need to extract the reference ligand stored in the target's PDB file.
After clicking the "Add Target" button, the new library will appear in the target library cards list and will also be available for selection when creating a new project.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_add_target.png)

### Editing and deleting targets

You can edit and/or delete a previously saved target. To do this, in the system interface, in the main window of the target list, on the flashcard of the corresponding target, select the item "Edit target" or "Delete target". Editing is available only for targets that belong to this user and have the status "ready". You can edit the name, type of use, description, author and source. The functionality of editing a target is similar to the functionality of creating a target with previously filled in fields. Deletion is available only for targets that belong to this user. When deleting, the target is transferred to the status "archived".

### Ligands

When you select the "Library-Ligands" section of the side menu, a list of available ligand libraries is displayed in the working window.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_library_ligands.png)

The ligand libraries are displayed as flashcards. Each card contains the following information:
- Access mode,
- The author or the authors,
- The creator (the user who added the library),
- A short description.
  
Editing and deleting libraries are available for libraries created by the user.
To add a new library of ligands, click the "Add" button in the main work window and fill out the appropriate form.
When filling out the form, you must provide the following information:
- The name of the library (collection) of ligands,
- Brief description of the ligand library,
- Authorship of the library,
- The source from which the library was obtained,
- Library access mode (closed, private, shared),
- The source of the ligand file – if the file size is small, it can be downloaded directly; if the file size is large, you can specify a link to it on the file sharing site.
After clicking the "Add a ligand collection" button, the new library will appear in the list of ligand library cards, and will also be available for selection when creating a new project.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_add_ligands_library.png)

### Editing and deleting ligand collections

You can edit and/or delete a previously saved ligand collection. To do this, in the system interface, in the main window of the ligand collection list, on the flashcard of the corresponding ligand collection, select the item "Edit ligand collection" or "Delete ligand collection". Editing is available only for ligand collections that belong to this user and have the status "ready". You can edit the name, type of use, description, author and source. The functionality of editing a ligand collection is similar to the functionality of creating a ligand collection with previously filled in fields. Deletion is available only for ligand collections that belong to this user. When deleting, the ligand collection is transferred to the status "archived".

## Auxiliary functionality

The auxiliary functionality of the system provides additional features for user convenience and system operation. The auxiliary functionality includes sections:
- News – information about important system events such as software updates, creation and completion of publicly available projects,
- Notifications – User notifications about events in projects, such as completing a certain number of tasks or finding a certain number of hits in the user's projects,
- Settings – system settings related to interaction with a specific user.
The sections are accessed from the corresponding items in the side menu.

![image](https://github.com/hitvisc/hitvisc/blob/main/img/tutorial_additional.png)
