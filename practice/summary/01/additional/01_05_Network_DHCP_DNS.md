# 01.05 Network - DHCP, DNS

## Описание
Во внутренней сети выдавать адреса вручную может быть утомительно, проще поставить на сервер DNS и DHCP-сервер, чтобы переложить эту ответственность на сервер.  
dnsmasq - простой и легкий кеширующий DNS и DHCP-сервер

## Установка
`apt install dnsmasq`

## Настройка
```
# Настройки /etc/dnsmasq.conf
# интерфейсы и адреса, на которых будет работать сервер
interface= vmbrl, vmbr2
listen-address= 127.0.0.1, 192.168.34.2, 192.168.35.2

# выдаваемые клиентам диапазоны адресов, перед каждой настройкой указывается сетевой интерфейс к которой она применяется
dhcp-range=interface:vmbr1,192.168.34.101,192.168.34.199,255.255.255.0,12h
dhcp-range=interface:vmbr2,192.168.35.101,192.168.35.199,255.255.255.0,12h

dhcp-option=interface:vmbr1,3,192.168.34.2
dhcp-option=interface:vmbr1,6,192.168.34.2
# Option 3(шлюз) и 6 (DNS-сервер).
dhcp-option=interface:vmbr2,3
dhcp-option=interface:vmbr2,6
```
Почему другие настройки для vmbr2?
Так как нам нужно передавать ей только IP-адрес и маску, без шлюза и серверов имен, то соответствующие опции следует передать пустыми, иначе будут переданы опции по умолчанию, где в качестве этих узлов будет передан адрес сервера.
После настройки перезапустить службу: `service dnsmasq restart`