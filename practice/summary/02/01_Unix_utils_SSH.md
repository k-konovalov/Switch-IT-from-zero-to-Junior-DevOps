# 01_01 Unix utils - Работа с SSH

## Теория
Защищенный сетевой протокол для удалённого управления сервером через интернет поверх TCP (22 порт). В Unix исползьуется встроенный клиент OpenSSH, для Windows обычно используют Putty.  
**Возможности**:
- удаленный запуск программ и выполнения команд на сервере через командную строку;
  - замена telnet;
- передачи данных (почта, видео, изображения и другие файлы) через защищённое соединение;
  - заменить ftp (sftp);
- socks-прокси — обеспечить локальное устройство или целую сеть socks-прокси через удалённую машину;
- алиасы;

**Этапы подключения**:
- Установка TCP соединения
- Открытие защищенного канала: способ шифрования (можно выбрать) и сжатия
- Аутентификация пользователя: при помощи открытого ключа (по-дефолту)

**Способы аутентификации**:
- пароль
- ключи (ssh-keygen)

**Конфиги**:
 - глобальные: `/etc/ssh`
 - пользовательские: `~/.ssh/`
 - `man ssh_config`: документация
 - содержание:
   - config: файл настройки клиента.
   - authorized_keys: список ключей для доступа к этому пользователю
   - known_hosts: список ключей для хостов, к которым ранее уже было произведено подключение
   - id_*: закрытые ключи доступа для текущего устройства, * - имя алгоритма шифрования
   - id_*.pub: публичные ключи доступа, которые используются для подключения к другим устройствам. * - имя алгоритма шифрования

**Описание содержимого config**
- пример:
    - ```
       Host my_server
       Hostname fd12::8
       Port 8022
       IdentityFile ~/.ssh/id_ed25519
       IdentitiesOnly yes
       ```
- `PubkeyAuthentication yes`: включение атунтификации по ключу
- `Port 8022`: смена порта подключения
- отключение аутентификацию по паролю
  - PasswordAuthentication no
  - KbdInteractiveAuthentication no
- `PermitRootLogin no`: запрет входа пользователю root
- `PermitEmptyPasswords no`: запрет пустого пароля

**Команды**
- Типичная команда: `ssh {user}@{host}`
  - host: ip или доменное имя
  - user: пользователь
  - -p 2022: смена порта
    - если нужно указать порт отличный от стандартного (TCP: 22), то используется -p: `ssh root@10.10.10.0 -p 2022`
  - -v: вывод диагностических сообщений
- `scp`: копирование файлов на удалённый хост и обратно через SSH
  - пример: `scp my_file user@host:~/`
- `ssh user@host -D 1080`: активировать socks прокси
- `ssh user@host some_command`: выполнение команды
- `ssh-copy-id user@host`: копирвоание публичного ключа на хост
  - `ssh-copy-id -i ~/.ssh/id_ed25519 user@host`: указание конкретного ключа для копирования
- `systemctl restart sshd`: перезапуск SSH сервера

### Смена порта (сервер)
- `nano /etc/ssh/sshd_config`: отредактировать конфиг
- раскомментировать `#port 22` и поменять на свой
- `/etc/init.d/sshd restart` или `service ssh restart`: перезагрузка сервиса

### ssg-agent (клиент)
Это сервис, который хранит ключи в расшифрованном виде после первого использования. Его необходимо установить / держать запущенным на машине, которая будет подключаться.  
При первом использовании ключа необходимо будет ввести пароль, после чего сервис запомнит ключ и будет в дальнейшем использовать его не требуя пароля.
Пробрасывать ключ на удалённые машины, в файле настроек `~/.ssh/config` добавить:
- не секьюрно, альтернатива `ProxyJump`
- по-дефолту лучше держать выключенным
```
Host my_server
ForwardAgent yes
```
Чтобы ключи автоматически (после первого использования) добавлялись в агент, в файле настройки клиента `~/.ssh/config` добавить: `AddKeysToAgent yes`.

### Меры защиты SSH-сервера
- Перевести с SSH на нестандартный порт
- Запретить вход под пользователем root параметром PermitRootLogin
- Запретить вход по паролю параметром Password/Authentication в config-е SSH-сервера
- Настроить двухфакторную аутентификацию через SSH.

### sudoers
Файл sudoers нужен для ограничения доступа к функциям и программа т.е, чтобы определять, какие **пользователи** или **группы** могут запускать какие **команды** с правами суперпользователя (root) или других учётных записей.
Основный конфигурационный файл sudoers находится по пути /etc/sudoers, а дополнительные конфиги в /etc/sudoers.d/.
- `sudo visudo`: команда для безопасного редактирования основного файла: 
  - проверяет синтаксис перед закрытием
  - `-f /etc/sudoers.d/config_file`: для того, чтобы открыть отдельный файл
- `sudo update-alternatives --config editor`: указать иной редактор
#### Пример
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
#### Правила заполнения
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

#### Defaults
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

#### User specification
- `root    ALL=(ALL:ALL) ALL`: определяет привилегии sudo для пользователя root.
  - имя пользователя или группы `%admin`
  - список хостов: ALL означает, что правило применяется ко всем хостам и IP-адресам.
  - пользователи: ALL означает, что пользователь может запускать команды от имени любого пользователя
  - группы: ALL означает, что пользователь может запускать команды от любой группы
  - команд: ALL означает разрешение на выполнение любых команд от лица всех групп и пользователей
  - пример: `timeweb-backup ALL=(root) /bin/mount /root/backup.d`

#### Псевдонимы (alias)
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

##### Пример использования псевдонимов
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

#### Подключенние других файлов
Подключение файлов из этого каталога нужно для приложений, которые после установки изменяют привилегии sudo.
- `#includedir /private/etc/sudoers.d`
- редактировать нужно безопасно через visudo.

## 1. Задание - Настрой доступы к своим серверам через ssh (пароль).
- `apt-get install ssh`: устанавливаем, если почему-то нет
  - или `openssh-client`
- `ssh admin@10.0.0.0 -p 2022`
    - admin: пользователь
    - 10.0.0.0: ip-адрес назначения
    - -p 2022: смена порта
- При первом подсоединении соглашаемся на хранение хэша
- Вводим пароль от указанного пользователя

## 2. Задание - Настрой доступы к своим серверам через ssh keys
Сменить пароль на ключ можно с помощью команды ssh-keygen.
- сгенерировать ключ (локально): 
  - `ssh-keygen -C Kirills-home-notebook -t ed25519 -c`
    - -t сменить алгоритм шиврофвания (rsa по-дефолту)
    - -c запросить смену комментария (-C указать сразу)
  - будет создано два файлa (открытый ключ id_*.pub и закрытый)
    - закрыты для локального устройства
    - открытый для авторизации на других
- Передача на ВМ: через специальную команду `ssh-copy-id`
  - `ssh-copy-id -p 22101 -i ~/.ssh/id_ed25519.pub kirillkonovalov@10.10.10.10`:
    - -p: смена порта
    - -i: путь к файлу
- Передача на ВМ: через копирование ключа на вм и команду `scp`
  - `scp -P 22101 ~/.ssh/id_ed25519.pub kirillkonovalov@10.0.0.0:~/`: 
    - -P: смена порта
  - нужно создать / изменить файл `~/.ssh/authorized_keys` (удаленно)
    - где ~, каталог пользователя, под которым нужно заходить
  - скопировать туда содержимое открытого ключа (*.pub) с правами 600, иначе ssh его не примет
    - `cat id_ed25519.pub >> ~/.ssh/authorized_keys`
    - `chmod 600 ~/.ssh/authorized_keys`
- Чтобы не спрашивал `Enter passphrase for key` нужно использовать `ssh-agent` 
  - вручную: 
    - `eval "$(ssh-agent -s)"`: запуск агента
    - `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`: добавить ключ в агент и keychain (macOS)
  - создать сервис
    - `~/.config/systemd/user/ssh-agent.service`: создать файл
      - ```
        [Unit]
        Description=SSH key agent
  
        [Service]
        Type=simple
        Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
        ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK
  
        [Install]
        WantedBy=default.target
       ```
    - `~/.config/environment.d/ssh_auth_socket.conf`: создать или добавить в файл
      - `SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"`
    - `systemctl --user enable --now ssh-agent`: активировать сервис
    -  Чтобы ключи автоматически добавлялись в агент
      - добавить строчку `AddKeysToAgent yes` в файл `~/.ssh/config`

## 3. Задание - настройка прав пользователя через sudoers
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

## Troubleshooting
- `Warning remote host identification has changed!`
  - Почему-то сменилась хеш сумма сервера. Например, из-за подключения по локальному / внешнему адресу к одному серверу.
  - Удалить `~/.ssh/known_hosts`
- `Enter passphrase for key`
  - проверить ssh-agent (запущенный сервис, config, добавлен ли ключ)

## Вопросы к ментору
- Порт для shh лучше менять на самом сервере или просто учитывать при пробросе портов (22100 -> 22)?
- Как различать ключи от разных пользователей? суффикс с именем пользователя? В каком формате коммент к ключу? (почта / логин стафа / локальный логин)
- Если отключена парольная аутентификация, а ключи потеряли / затерли, то удаленный доступ не возможен?
- Опасен ли проброс ключей `ForwardAgent yes`?
- Например, уволился сотрудник, нужно удалить все его открытые ключи со всех серверов. Как это всë отслеживать и учитывать?
- sudoers: Есть ли какой-то джентельменский набор правил к sudoers?

## Полезные ссылки
- [Что такое SSH](https://help.reg.ru/support/hosting/dostupy-i-podklyucheniye-panel-upravleniya-ftp-ssh/chto-takoye-ssh)
- [Как сменить порт доступа к SSH на выделенном сервере](https://help.reg.ru/support/vydelennyye-servery-i-dc/dedicated/rabota-s-dedicated/rabota-s-dedicated-po-ssh#1)
- [Коротко об SSH](https://habr.com/ru/sandbox/166705/)
- [Знакомство с SSH](https://habr.com/ru/articles/802179/)
- [Памятка пользователям ssh](https://habr.com/ru/articles/122445/)
- [Про SSH Agent](https://habr.com/ru/companies/skillfactory/articles/503466/)
- [как настроить ssh-agent](https://www.prolinux.org/post/2021/02/11/kak-nastroit-ssh-agent/)
- [Хабр | Безопасность SSH](https://habr.com/ru/companies/slurm/articles/694222/)
- [Sudo: настройка файла /etc/sudoers](https://ruvds.com/ru/helpcenter/znakomstvo-s-sudo/sudo-nastroika-faila-etc-sudoers/)
- [Редактирование файла Sudoers](https://timeweb.cloud/tutorials/linux/redaktirovanie-fajla-sudoers)