## System installation

Working computer - the computer of the system administrator, from which the preliminary configuration of the HiTViSc system is performed and commands for deploying the system to the remote server are sent. Remote server - the computer on which the HiTViSc system will be directly deployed, including all its components, databases and the end user web interface.

1. Download the source code and prepare the working computer:

```
git clone git@github.com:hitvisc/hitvisc.git
cd hitvisc/install
ssh-keygen #(3 раза нажать Enter для установки директории с ключами по умолчанию и пустого пароля)
cat ~/.ssh/id_rsa > keys/ansible.key
chmod 600 keys/ansible.key
cat ~/.ssh/id_rsa.pub #(скопировать содержимое публичного ключа для шага 2)
sudo apt install ansible
```

2. Prepare the remote server for work. Let's assume that the administrator account (root) is accessible via ssh at the IP address [IP address] with password ansibleRootPasswd. During the installation process, there will be created a user account named ansible, with password ansiblePasswd, on the server.

```
ssh root@[IP address] #(ввести пароль пользователя root по запросу)
useradd -m --shell /bin/bash ansible
passwd ansible #(ввести пароль для создаваемого пользователя: например, ansiblePasswd)
sudo usermod -a -G sudo ansible
useradd -m --shell /bin/bash hitviscadm
addgroup hitvisc
sudo usermod -a -G hitvisc hitviscadm
sudo usermod -a -G hitvisc ansible
sudo usermod -a -G www-data hitviscadm
mkdir -p /app/hitvisc/front
chown -R ansible:hitvisc /app/
hostname #(выведенное имя хоста понадобится для установки параметров на рабочем компьютере на шаге 3)

apt install -y git vim 
su ansible
cd /home/ansible
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
npm install -g pm2
vim ~/.ssh/authorized_keys #(вставить с новой строки содержимое публичного ключа рабочего компьютера, скопированное на шаге 1)
```

3. Set up access settings to the remote server on your work computer:

```
cd hitvisc/install
cp group_vars/TargetServers.example group_vars/TargetServers
vim group_vars/TargetServers #(установить в файле group_vars/TargetServers актуальные параметры boinc_project_host, boinc_url_base и boinc_db_host, используя имя хоста и внешний ip-адрес удаленного сервера [IP address])
cp source/hitvisc/main/hitvisc.conf.example source/hitvisc/main/hitvisc.conf 
vim inventory.txt #(установить в файле inventory.txt имя хоста и внешний ip-адрес удаленного сервера [IP address])
```

If you wish, you can set your own parameter values ​​in the group_vars/TargetServers and source/hitvisc/main/hitvisc.conf files.

You can choose the settings associated with the BOINC project running inside the HiTViSc system at your own discretion. They set the parameters for accessing the BOINC project and are specified in the group_vars/TargetServers file. The boinc_project_name parameter defines a unique, unchangeable URL for the BOINC project. The boinc_project_caption parameter defines the project name displayed in the BOINC client. If you plan to involve a wide range of volunteers in the calculations, it is recommended to think about the project name in advance.

>boinc_project_host           : [REPLACE WITH YOUR SERVER HOSTNAME]  
>boinc_url_base               : http://[REPLACE WITH YOUR SERVER IP ADDRESS]/  
>boinc_project_home           : hitboinc  
>boinc_db_host                : [REPLACE WITH YOUR SERVER HOSTNAME]  
>boinc_db_name                : hitboinc  
>boinc_db_user                : hitviscadm  
>boinc_db_password            : hitviscadmPasswd  
>boinc_project_name           : hitboinc  
>boinc_project_caption        : HiTViSc@home  

The following group of parameters in the source/hitvisc/main/hitvisc.conf file describes the basic system settings of the HiTViSc system, and it is recommended to leave them unchanged.

>registry_database        = hitvisc  
>hitvisc_api_dir          = /app/hitvisc/api  
>hitvisc_main_dir         = /app/hitvisc/main  
>hitvisc_data_dir         = /app/hitvisc/data  
>hitvisc_bio_dir          = /app/hitvisc/bio  
>hitvisc_log_dir          = /app/hitvisc/log  
>hitvisc_tmp_dir          = /app/hitvisc/tmp  

4. Install the back-end on a remote server.

The deployment of the back-end part of the System is provided by Ansible scripts, which perform all the necessary actions to install and configure the system software. Sequential execution of scripts allows you to install the system environment step by step with the ability to adjust, if necessary, in case of errors.
To install the back-end, the following set of commands is executed:

```
ansible-playbook hitvisc-install.yml -K
ansible-playbook hitvisc-main-install.yml -K
ansible-playbook boinc-install.yml -K
ansible-playbook hitvisc-boinc-install.yml -K
ansible-playbook postgresql-install.yml -K
ansible-playbook registry-install.yml -K
ansible-playbook third-party-install.yml -K
```

As a result of successful execution of the commands, all necessary system directories will be created in the directory tree ``/app/*``, and the necessary tables in the database will be created and filled with a basic set of data.

5. Install the front-end on the remote server.

```
su ansible
cd /home/ansible
git clone https://github.com/hitvisc/hitvisc.git # LAST
cd /home/ansible/hitvisc/frontend/nuxt-client/src/
npm install
npm run build
cd /home/ansible/hitvisc/frontend/backend/src/
npm install
npm run build

cd /app/hitvisc/front
mkdir -p /app/hitvisc/front/app/api
mkdir -p /app/hitvisc/front/app/client
cp -r /home/ansible/hitvisc/frontend/backend/src/dist /app/hitvisc/front/app/api/dist
cp -r /home/ansible/hitvisc/frontend/backend/src/node_modules /app/hitvisc/front/app/api/node_modules  
cp -r /home/ansible/hitvisc/frontend/nuxt-client/src/.output /app/hitvisc/front/app/client/.output
mkdir -p /app/hitvisc/front/sysdir
mkdir -p /app/hitvisc/front/storage
cp /home/ansible/hitvisc/frontend/upload_settings.conf.example /app/hitvisc/front/upload_settings.conf
cp /home/ansible/hitvisc/frontend/pm2.config.js /app/hitvisc/front/pm2.production.config.js
vim /app/hitvisc/front/pm2.production.config.js #(установить актуальные настройки)
exit #(вернуться под пользователем root)
chown -R hitviscadm:hitvisc /app
```

In the settings file ``/app/hitvisc/front/pm2.production.config.js`` the following group of parameters sets the rules for accessing the mail account that will be used in the system to confirm user registrations/password recovery:

>EMAIL_HOST: "smtp.yandex.ru", (must be replaced with the SMTP server host of the mail account)
>EMAIL_PORT: 465, (must be replaced with the port number of the mail account)
>EMAIL_USER: "user@yandex.ru", (must be replaced with the e-mail address of the mail account)
>EMAIL_PASSWORD: "apppassword", (must be replaced with the password of the mail account application)

To launch the front-end, you need to run commands on the remote server

```
su hitviscadm
cd /app/hitvisc/front
pm2 start pm2.production.config.js
```

6. Complete the database preparation on the work computer.

``
ansible-playbook registry-finalize.yml
``

After successful installation of the back-end and front-end parts of the System, the user web interface of the System is accessible from a web browser at an address of the form http://ADDRESS:PORT, in which the substring ADDRESS is specified in the file install/inventory.txt in the variable

```
ansible_host=<ip-адрес удаленного сервера>
```

and the PORT substring is specified in the /app/hitvisc/front/pm2.production.config.js file in the variable

```
PORT: <web port number>
```












