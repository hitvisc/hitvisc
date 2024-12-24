# HiTViSc (High-Throughput Virtual Screening)

The high-performance distributed computing system for drug development, HiTViSc, is designed to conduct structure-based virtual screening and can be used to solve applied problems in the following areas:

:pill: development of new drugs;  
:pill: optimization of existing drugs;  
:pill: development and optimization of materials and other molecules with specified properties;  
:pill: prediction of molecule properties.

____

## Minimum hardware and operating system requirements for running and using the system:

- For the end user, it is recommended to use a personal computer with the following characteristics:
	- CPU with two or more cores and a clock rate of at least 2 GHz;
	- RAM of at least 4 GB;
	- Internet channel with a bandwidth of 10 Mbps;
	- Windows, Linux or MacOS OS with a standard set of system software;
	- Mozilla Firefox web browser version 132 or later, Chrome version 130 or later, Edge version 131 or later, Safari version 17 or later.
- For the server part of the system, it is recommended to use a server with the following characteristics:
	- CPU with two or more cores and a clock rate of at least 2 GHz;
	- RAM of at least 4 GB;
	- two 1 TB hard drives combined into RAID 1;
	- Internet channel with a bandwidth of 100 Mbps;
	- OS based on Linux kernel version 6.4 or higher.
- For the server part of the system, it is recommended to use the following versions of additional components and libraries:
	- Ansible version 2.10.8 or higher (installed on the working computer);
 	- Python version 3.10 (installed on the remote server);
	- NodeJS version 18 or higher (installed on the remote server when deploying the system);
	- pm2 version 5.4 or higher (installed on the remote server when deploying the system);
	- Anaconda version 2024.10-1 or higher (installed on the remote server when deploying the system, the link to the installation script is specified in the install/source/hitvisc/bio/install_conda.sh file);
	- BOINC server version 1.4-1.4.2 or higher (installed on the remote server when deploying the system, the archive with the source code is provided in the install/source/boinc directory);
	- OpenBabel version 3.1.1 or higher (installed on the remote server during system deployment by executing the install/source/hitvisc/bio/setup_hitvisc-bio_env.sh script);
	- MGLTools version 1.5.7 or higher (installed on the remote server during system deployment by executing the install/source/hitvisc/bio/setup_hitvisc-bio_env.sh script).
____
Before installing the system, make sure that the following files have the current settings:

:key: the install/group_vars/TargetServers file contains the settings for connecting to the remote server;  
:key: the install/inventory.txt file contains the IP address of the remote server;  
:key: the install/keys/ansible.key file contains the private OPENSSH key of the remote server;  
:key: The install/source/hitvisc/main/hitvisc.conf file contains system settings for the HiTViSc system.  

## Third-Party Libraries

The HiTViSc system relies on several third-party tools with open source:

- [BOINC](https://boinc.berkeley.edu/) (GNU LGPL license) to execute computational tasks of virtual screening in a distributed computing system;
- [AutoDock Vina](https://vina.scripps.edu/) (Apache license) and [CmDock](https://gitlab.com/Jukic/cmdock/) (GNU LGPL license) to perform molecular docking;
- [MGLTools](http://mgltools.scripps.edu/) (MOZILLA Open Source license and several other licenses - see [details](http://mgltools.scripps.edu/downloads/license-agreements)) to prepare the files of target and ligands for virtual screening;
- [OpenBabel](https://openbabel.github.io/) (GPL-2.0 license) to calculate chemical descriptors, convert the files of target and ligands into necessary formats;
- [Conda](https://github.com/conda/conda) (BSD-3 license) to install and manage software packages, create and use an isolated environment.




