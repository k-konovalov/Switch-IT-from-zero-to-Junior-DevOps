source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback

#Primary network interface
auto ens18
iface ens18 inet static
        address 192.168.174.2
        gateway 192.168.174.1