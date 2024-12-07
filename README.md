# HiTViSc (High-Throughput Virtual Screening)

Высокопроизводительная система распределенных вычислений для разработки лекарств HiTViSc предназначена для проведения виртуального скрининга на основе знания структуры мишени и может быть использована для решения прикладных задач по следующим направлениям:

:pill: разработка новых лекарственных средств;

:pill: оптимизация существующих лекарственных средств;

:pill: разработка и оптимизация материалов и иных молекул с заданными свойствами;

:pill: прогнозирование свойств молекул.

____

The high-performance distributed computing system for drug development HiTViSc is designed to perform structure-based virtual screening and can be used to solve applied problems in the following areas:

:pill: development of new drugs;

:pill: optimization of existing drugs;

:pill: development and optimization of materials and other molecules with specified properties;

:pill: prediction of molecule properties.
____

Установка системы производится на удаленном сервере. Перед началом работы убедитесь в наличии актуальных настроек в следующих файлах:

:key: файл install/group_vars/TargetServers содержит настройки подключения к удаленному серверу;

:key: файл install/inventory.txt содержит ip-адрес удаленного сервера;

:key: файл install/keys/ansible.key содержит приватный ключ OPENSSH удаленного сервера;

:key: файл install/source/hitvisc/main/hitvisc.conf содержит системные настройки системы HiTViSc.





