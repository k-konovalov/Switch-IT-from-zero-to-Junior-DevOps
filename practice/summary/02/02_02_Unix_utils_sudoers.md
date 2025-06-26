# 02_02 Unix utils - sudoers

## Теория
Файл sudoers нужен для ограничения доступа к функциям и программа т.е, чтобы определять, какие **пользователи** или **группы** могут запускать какие **команды** с правами суперпользователя (root) или других учётных записей.
Основный конфигурационный файл sudoers находится по пути /etc/sudoers, а дополнительные конфиги в /etc/sudoers.d/.
- `sudo visudo`: команда для безопасного редактирования основного файла: 
  - проверяет синтаксис перед закрытием
  - `-f /etc/sudoers.d/config_file`: для того, чтобы открыть отдельный файл
- `sudo update-alternatives --config editor`: указать иной редактор

### Пример
```
# Defaults
Defaults env_reset
Defaults mail_badpass
Defaults secure_path="/us/local/sbin: /us/local/bin:/usr/sbin:/usr/bin:/sbin:/bin: /snap/bin"
# Host alias specification
# User alias specification
# Cmnd alias specification
# User privilege specification
root ALL=(ALL:ALL) ALL
# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL
# Allow members of group sudo to execute any command sudo
ALL=(ALL:ALL) ALL
# See sudoers(5) for more information
#includedir /etc/sudoers.d
```
### Правила заполнения
- редактировать через visudo
- располагать в начале файла более общие установки, ниже более частные
- в случае конфликта правил в приоритете более поздние.
- псевдонимы с большой буквы.
- блок комментариев
  - `# Однострочный комментарий`
```
##
# Многострочный комментарий
##
```

### Defaults
`Defaults {значение}`, например `Defaults passwd_tries=5`.  
Первые три строки — определяют настройки по умолчанию. Они обеспечивают перезапись пользовательских настроек, чтобы избежать работы вредоносных программ или переменных.
- `env_reset`: удаляет переменные пользователя, которые могут создаваться в системе и потенциально повлиять на работу в режиме суперпользователя.
- `env_keep {значение}`: сохранят от перезатирания переменную, например `env_keep += "BLOCKSIZE"`
- `mail_badpass`: указывает, что система будет отправлять на почту, указанную в настройках root, неудачные попытки получить неограниченные привилегии.
- `secure_path`: определяет PATH для sudo. Иными словами, она содержит каталоги, в которых ОС будет искать приложения. Переопределяя пользовательские настройки, мы избегаем выполнения потенциально вредоносных программ.
- `passwd_tries=5`: расширить количество попыток ввода с трёх (по умолчанию) до 5
- `passwd_timeout=5`: таймаут между попытками ввода неверного пароля
- `badpass_message="Your password is not correct!"`: замена стандартного сообщения пароля
- `timestamp_timeout=0`: если нужно вводить пароль каждый раз
- `logfile=/var/log/sudo.journal.log`: задать файл записи логов ввода неверного пароля

### User specification
- `root    ALL=(ALL:ALL) ALL`: определяет привилегии sudo для пользователя root.
  - имя пользователя или группы `%admin`
  - список хостов: ALL означает, что правило применяется ко всем хостам и IP-адресам.
  - пользователи: ALL означает, что пользователь может запускать команды от имени любого пользователя
  - группы: ALL означает, что пользователь может запускать команды от любой группы
  - команд: ALL означает разрешение на выполнение любых команд от лица всех групп и пользователей
  - пример: `timeweb-backup ALL=(root) /bin/mount /root/backup.d`

### Псевдонимы (alias)
- User_Alias: Псевдоним пользователей, которые будут использовать sudo.
  - `User_Alias     GROUPA = user1, user2, user3`
- Host_Alias: Псевдоним хоста. Представляет собой список IP-адресов или хостов, с которых выполняются программы. 
- Cmnd_Alias: Псевдоним команды.
  - `Cmnd_Alias      RSTRT = /sbin/restart, /sbin/reboot`
- Runas alias: Псевдоним пользователей, от имени которых команды будут выполняться.
**Роли команд**
- NOPASSWD: разрешение выполнение без пароля
  - `GROUPA      ALL = NOPASSWD: /usr/bin/apt update`: для всех пользователей из группы А разрешить выполнение команды update без запроса пароля 
  - `GROUPC      ALL = RSTRT`
- NOEXEC: запрет выполнения

#### Пример использования псевдонимов
Разрешить всем пользователям группы admin обновлять пакеты Ubuntu, но без ввода пароля
```
Cmnd_Alias APT_UPDATE = /usr/bin/apt-get update,/usr/bin/apt-get upgrade
...
%admin ALL=(ALL) NOPASSWD: APT_UPDATE
```
Разрешение на монтирование, но запрет на размонтирование
```
Users ALL = (root) NOPASSWD: /bin/mount
Users ALL = (root) NOEXEC: /bin/umount
```
Разрешить пользователям запускать скрипты резервирования системы от пользователя root.
```
User_Alias Users = timeweb-backup,remote,hal9000
Host_Alias REMOTE = timeweb.cloud
Cmd_Alias Cmds = /root/backup
Users Hosts = (root) Cmds
```
Разрешение пользователю перезапускать только определённую службу
`user ALL= /bin/systemctl restart nginx`

### Подключенние других файлов
Подключение файлов из этого каталога нужно для приложений, которые после установки изменяют привилегии sudo.
- `#includedir /private/etc/sudoers.d`
- редактировать нужно безопасно через visudo.

## Задание - настройка прав пользователя через sudoers
- `sudo visudo`: открываем файл 
- добавляем
```
Defaults badpass_message="Badass! Try again with different pass!"
# !Предварительно создав файл логов
Defaults logfile=/tmp/log/sudo.journal.log
# Разрешить обновление зависимостей без пароля
User_Alias     GROUPA = kirillkonovalov, root
Cmnd_Alias APT_UPDATE = /usr/bin/apt-get update,/usr/bin/apt-get upgrade,/opt/homebrew/bin/brew update

GROUPA ALL = NOPASSWD: APT_UPDATE
```

## Вопросы к ментору
- Есть ли какой-то джентельменский набор правил к sudoers?

## Полезные ссылки
- [Хабр | Безопасность SSH](https://habr.com/ru/companies/slurm/articles/694222/)
- [Sudo: настройка файла /etc/sudoers](https://ruvds.com/ru/helpcenter/znakomstvo-s-sudo/sudo-nastroika-faila-etc-sudoers/)
- [Редактирование файла Sudoers](https://timeweb.cloud/tutorials/linux/redaktirovanie-fajla-sudoers)