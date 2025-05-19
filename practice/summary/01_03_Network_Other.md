# 01.04. Network - Other

## Полезные команды при работе с сетью
- `systemctl restart networking`
  - Изменения в `/etc/network/interfaces` применяются не сразу, команда позволяет перезапустить сеть
- `cat /etc/network/interfaces`
  - Посмотреть текущую настройку интерфейсов
- `cat /etc/resolv.conf`
  - Посомтреть текущую настройку локлаьного DNS сервера
  - `nameserver 192.168.0.1` (при условии, что это IP сервера-маршрутизатора в LAN) будет означать, что за настройками DNS нужно обратиться к маршрутизатору
  - Если записей nameserver нет, то по умолчанию используется сервер имен на локальной машине.
- Посмотреть состояние сетевых интерфейсов: `ip a`, `ip l`
  - Стоит обращать внимание на название интерфейса, выданный ip и state (UP или DOWN)
- Записать значение `sysctl -w {свойство}={значение}`
    - Пример: `sysctl -w net.ipv4.ip_forward=1` - разрешить проброс портов
- Прочитать значение `sysctl {свойство}`
    - Пример: `sysctl net.ipv4.conf.enp6s0.send_redirects` -
- Проверка порта на открытие - [link](https://kb.synology.com/ru-ru/DSM/tutorial/Whether_TCP_port_is_open_or_closed)
  - macOS: nc -zv + IP-адрес или имя хоста + номер портаv `nc -zv www.synology.com 443`
  - Linux: telnet + IP-адрес или имя хоста + номер порта `telnet www.synology.com 1723`
  - Windows: аналогично Linux, если успешно - будет отоброжаться курсор, если неуспешно - connection refused
- Посмотреть состояние файрволла Proxmox: `pve-firewall status`