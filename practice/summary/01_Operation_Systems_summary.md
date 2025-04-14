# 01_Operation_Systems Summary

## Глоссарий
- ВМ: sandbox окружение, в котором эмулируется или прокидывается железное оборудование (диск, видеокарта, флешка, звук и т.п).  
- Гипервизор: ПО для запуска нескольких ВМ на одной физической машине
- X - Server: графическое окружение (GUI) для Unix 
- GRUB / UEFI: графическая оболочка над BIOS
- NAT: Network Address Translation использование адреса одного сервера для нескольких виртуальных машин
- Протокол IP: маршрутизируемый протокол сетевого уровня (L3), предназначенный для передачи данных между сетями. Единицей передачи данных на уровне IP-протокола является пакет.
- Сетевой мост (bridge) - При работе в режиме сетевого моста виртуальные машины будут находиться в одной подсети с гипервизором и использовать IP-адреса этой подсети.
- conntrack система отслеживания состояния соединений и принадлежностью пакетов этим соединениям
- MASQUERADE: (маскарадинг) iptables action in nat table, algorithm that allows one to route traffic without disrupting the original traffic. Маскарадинг самостоятельно получает IP-адрес от заданного сетевого интерфейса и не требует его явного указания.
- DNS: Domain Name System, преобразует доменные имена, удобные для человеческого восприятия (например, www.amazon.com), в IP-адреса, понимаемые машиной (например, 192.0.2.44).

## Теория

### Чем различаются дистрибутивы Linux
Различия:
- Глобальные
  - цели (десктоп, Server, IOT, Cloud)
  - надежность / стабильность (LTS)
- Технические
  - с привязкой к железу или переносимые
  - версия ядра (systemd у Debian / Ubuntu,)
  - пакеты (RPM-пакеты, DPK-пакеты)
  - X - сервер (Gnome ,KDE, Cinnamon и т.п)

### Образ или ВМ
Образ - слепок диска, позволяющий совершать какие-либо действия. Как просто установку из него, так и полноценную работу.
ВМ - слепок диска, как правило с установленной ОС.

### VirtualBox, VMWare, Parallels, vagrant, QEMU
- VirtualBox: open source Desktop решение для виртуализации.
- VMWare: corporate Desktop решение для виртуализациии.
- Parallels: corporate Desktop решение для виртуализациии.
- QEMU: open source Desktop решение для виртуализации.

## 1. Базовая установка

### 1.1 Установка Debian 
Решил взять Proxmox, чтобы сразу привыкать к кластерам и не устанавливать ручками с флешки (навыком накатывания флешки из образов обладаю), внутри у него Debian. 

#### Установка Proxmox
Proxmox Virtual Environment - open source платформа виртуализации на основе гипервизора KVM.
- [Домашний сервер на базе Proxmox](https://habr.com/ru/companies/banki/articles/827760/)
- CE скрипты после установки [старое](https://github.com/tteck/Proxmox?tab=readme-ov-file) -> [новое](https://github.com/community-scripts/ProxmoxVE/blob/main/misc/post-pve-install.sh)

##### Загрузка образов в Proxmox


##### Настройка сети в Proxmox
Решил настроить сеть между хостом и дочерними ВМ в режиме сетевого моста (bridge). ВМ и Хост будут в одной подсети и использовать IP-адреса этой подсети т.н [внешняя сеть](https://interface31.ru/tech_it/2019/10/nastraivaem-set-v-proxmox-ve.html).  
DHCP / DNS сервером выступает сетевой маршрутизатор. Во всех случаях нужно учесть, что порты открыты на роутерах / хосте / сетевых брандмауерах.
![PVE-network-configuration-002.png](img/01/PVE-network-configuration-002.png)

###### Хост
Рабочий вывод после `nano /etc/network/interfaces`
```
auto lo
iface lo inet loopback

auto enp6s0
iface enp6s0 inet dhcp # Позволяет получить ip динамически

auto vmbr0
iface vmbr0 inet static            # Сетевой мост
        address 192.168.174.100/24 # ip адресс выдан статически на маршрутизаторе
        gateway 192.168.174.1      # Локальный адрес домашнего сетевого маршрутизатора
        bridge-ports enp6s0        # через какой сетевой интерфейс выход в интернет (ethernet / RJ-45)
        bridge-stp off
        bridge-fd 0
# Host external network

source /etc/network/interfaces.d/*
```
Рабочий вывод после `nano /etc/resolv.conf` -
```
domain fritz.box
search fritz.box
nameserver 192.168.174.1 # Локальный адрес домашнего сетевого маршрутизатора
```
Рабочий вывод после `iptables -t nat -L`: пустая таблица.

###### Дочерняя VM
- Network Device: Intel E1000
```
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback

#Primary network interface
auto ens18
iface ens18 inet static
        address 192.168.174.2
        gateway 192.168.174.1
```

### 1.2 Создание n ВМ
- Из дистрибутивов взял Debian 12 из образа. 
- На основе образа завел 3 виртуалки под QEMU, специально не стал клонировать, а именно через Create VM.
- Нейминг VM: n.child.debian
- Каждую вручную установил через Graphical install.
- По-дефолту завел пользователя root и kirillkonovalov.

## 2. Создание пользователя, добавление / убавление прав пользователей

### 3. Работы в консольных редакторах (vim, nano, mc)

### 4. Работа с пакетным менеджером apt

## Вопросы к ментору
- Как размечать диски в Unix?
  - Предлагамая Схема разметки:
    1: Все файлы в одном разделе (рекомендуется новичкам) [*],
    2: Отдельный раздел для /home,
    3: Отдельные разделы для /home, /var u /tmp,
  - ExFat или ext4?
- Сеть
  - Какой тип сети используется для гипервизоров? сетевой мост?
  - VM генерирует рандомны MAC. А что если будут коллизии?
  - Как пробросить ВМ за NAT?

## Полезные ссылки
- [Yandex Cloud Marketplace](https://yandex.cloud/ru/marketplace?categories=os&pageSize=75)
- [Что такое дистрибутив Linux](https://ruweb.net/articles/distributiv-linux-chto-eto)
- [В чем разница между дистрибутивами linux и какой выбрать?](https://qna.habr.com/q/192159)
- [Установка и первоначальная настройка Debian 11 для сервера](https://interface31.ru/tech_it/2022/08/linux-nachinayushhim-ustanovka-i-pervonachal-naya-nastroyka-debian-11-dlya-servera.html)
- Сеть
  - [Основы iptables для начинающих. Часть 1. Общие вопросы](https://interface31.ru/tech_it/2020/02/osnovy-iptables-dlya-nachinayushhih-chast-1.html)
  - [Основы iptables для начинающих. Часть 2. Таблица filter](https://interface31.ru/tech_it/2020/09/osnovy-iptables-dlya-nachinayushhih-chast-2-tablica-filter.html)
  - [Основы iptables для начинающих. Часть 3. Таблица nat](https://interface31.ru/tech_it/2021/07/osnovy-iptables-dlya-nachinayushhih-chast-3-tablica-nat.html)
  - [Основы iptables для начинающих. Часть 4. Таблица nat - типовые сценарии использования](https://interface31.ru/tech_it/2021/08/osnovy-iptables-dlya-nachinayushhih-chast-4-tablica-nat-tipovye-scenarii-ispolzovaniya.html)
- Proxmox
  - [Установка сети в Proxmox](https://help.reg.ru/support/vydelennyye-servery-i-dc/administrirovaniye-vydelennykh-serverov/ustanovka-i-nastroyka-seti-v-proxmox-ve#1)
  - [Настраиваем сеть в Proxmox](https://interface31.ru/tech_it/2019/10/nastraivaem-set-v-proxmox-ve.html)