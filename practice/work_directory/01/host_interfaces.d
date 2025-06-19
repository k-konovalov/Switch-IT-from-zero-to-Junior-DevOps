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