# HiTViSc (High-Throughput Virtual Screening)

The high-performance distributed computing system for drug development, HiTViSc, is designed to conduct structure-based virtual screening and can be used to solve applied problems in the following areas:

:pill: development of new drugs;  
:pill: optimization of existing drugs;  
:pill: development and optimization of materials and other molecules with specified properties;  
:pill: prediction of molecule properties.

____

## Минимальные аппаратные и операционные технические требования для запуска и использования системы:
- Для работы конечного пользователя рекомендуется использовать персональный компьютер со следующими характеристиками:
	- процессор с двумя или более ядрами и тактовой частотой 2ГГц или выше;
	- оперативная память 4Гб или выше;
	- канал Интернет пропускной способностью 10 Мбит;
	- ОС Windows, Linux или MacOS со стандартным набором системного программного обеспечения;
	- веб-браузер Mozilla Firefox версии 132 или новее, Chrome версии 130 или новее, Edge версии 131 или новее, Safari версии 17 или новее.
- Для работы серверной части системы рекомендуется использовать сервер со следующими характеристиками:
	- процессор с двумя или более ядрами и тактовой частотой 2ГГц или выше;
	- оперативная память 4Гб или выше;
	- два жестких диска 1Тб, объединенных в RAID 1;
	- канал Интернет пропускной способностью 100 Мбит;
	- ОС на базе ядра Linux версии 6.4 или выше. 
- Для работы серверной части системы рекомендуется использовать следующие версии дополнительных компонент и библиотек:
	- Ansible версии 2.10.8 или выше (устанавливается на рабочем компьютере);
	- NodeJS версии 18 или выше (устанавливается на удаленном сервере при разворачивании системы);
 	- pm2 версии 5.4 или выше (устанавливается на удаленном сервере при разворачивании системы);
	- Anaconda версии 2024.10-1 или выше (устанавливается на удаленном сервере при разворачивании системы, ссылка на скрипт установки задается в файле install/source/hitvisc/bio/install_conda.sh);
	- BOINC сервер версии 1.4-1.4.2 или выше (устанавливается на удаленном сервере при разворачивании системы, архив с исходным кодом задается в директории install/source/boinc);
	- OpenBabel версии 3.1.1 или выше (устанавливается на удаленном сервере при разворачивании системы в ходе выполнения скрипта install/source/hitvisc/bio/setup_hitvisc-bio_env.sh);
	- MGLTools версии 1.5.7 или выше (устанавливается на удаленном сервере при разворачивании системы в ходе выполнения скрипта install/source/hitvisc/bio/setup_hitvisc-bio_env.sh).
____
Перед установкой системы убедитесь в наличии актуальных настроек в следующих файлах:

:key: файл install/group_vars/TargetServers содержит настройки подключения к удаленному серверу;  
:key: файл install/inventory.txt содержит ip-адрес удаленного сервера;  
:key: файл install/keys/ansible.key содержит приватный ключ OPENSSH удаленного сервера;  
:key: файл install/source/hitvisc/main/hitvisc.conf содержит системные настройки системы HiTViSc.

## Third-Party Libraries

The HiTViSc system relies on several third-party tools with open source:

- [BOINC](https://boinc.berkeley.edu/) (GNU LGPL license) to execute computational tasks of virtual screening in a distributed computing system;
- [AutoDock Vina](https://vina.scripps.edu/) (Apache license) and [CmDock](https://gitlab.com/Jukic/cmdock/) (GNU LGPL license) to perform molecular docking;
- [MGLTools](http://mgltools.scripps.edu/) (MOZILLA Open Source license and several other licenses - see [details](http://mgltools.scripps.edu/downloads/license-agreements)) to prepare the files of target and ligands for virtual screening;
- [OpenBabel](https://openbabel.github.io/) (GPL-2.0 license) to calculate chemical descriptors, convert the files of target and ligands into necessary formats;
- [Conda](https://github.com/conda/conda) (BSD-3 license) to install and manage software packages, create and use an isolated environment.




