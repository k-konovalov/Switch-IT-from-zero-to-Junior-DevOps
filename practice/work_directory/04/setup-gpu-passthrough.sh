cat /etc/default/grub |
sed "s/GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet amd_iommu=on iommu=pt\"/" |

update-grub

# Просмотр групп IOMMU
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})" >> test.txt
    done;
done;

cat test.txt | grep Nvidia >> test_filtered.txt

# уменьшение проблем с работой пробрасываемого железа в виртуальную машину
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf

# Загрузка необходимых драйверов
echo vfio >> /etc/modules-load.d/vfio.conf
echo vfio_iommu_type1 >> /etc/modules-load.d/vfio.conf
echo vfio_pci >> /etc/modules-load.d/vfio.conf
echo vfio_virqfd >> /etc/modules-load.d/vfio.conf

# запрещаем Proxmox'у использовать следующие драйвера видеокарт на хосте,

## AMD GPUs

echo "blacklist amdgpu" >> /etc/modprobe.d/blacklist.conf
echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf

## NVIDIA GPUs

echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia*" >> /etc/modprobe.d/blacklist.conf

## Intel GPUs

echo "blacklist i915" >> /etc/modprobe.d/blacklist.conf

lspci
lspci -n -s 01:00

lspci -n -s 01:00 | awk '{print $3}'

# 01:00.0 0300: 10de:1b81 (rev a2)
# 01:00.1 0403: 10de:10f0 (rev a1)

# Pапоминаем эти значения, после чего создаем/открываем для редактирования файл
# настроек #  и аккуратно прописываем:
#nano /etc/modprobe.d/vfio.conf
#options vfio-pci ids=10de:1b81,10de:10f0 disable_vga=1