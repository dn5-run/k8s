if [ -z $CT_PASSWORD ]; then
    echo 'Please set the "CT_PASSWORD" enviroment variable.'
    exit 1
fi

GATEWAY=192.168.1.1
NAMESERVER=1.1.1.1
CT_STORAGE=local-lvm
VM_LIST=(
    #vmid #vmhost   #cpu #mem  #vmip
    "1001 k8s-cp-01 2    2048  192.168.1.51"
    "1002 k8s-wk-01 4    16384 192.168.1.52"
)

wget https://github.com/dn5-run/k8s/releases/latest/download/template-ubuntu-22.04.tar.zst

for array in "${VM_LIST[@]}"
do
    echo "${array}" | while read -r vmid vmhost cpu mem vmip
    do
        pct create $vmid template-ubuntu-22.04.tar.zst \
            --cores $cpu \
            --hostname $vmhost \
            --memory $mem \
            --nameserver $NAMESERVER \
            --net0 name=eth0,bridge=vmbr0,firewall=true,gw=$GATEWAY,ip=$vmip/24 \
            --ostype ubuntu \
            --password $CT_PASSWORD \
            --unprivileged false \
            --storage $CT_STORAGE \
            --swap 0
        
        cat <<EOL >> /etc/pve/lxc/$vmid.conf
lxc.apparmor.profile: unconfined
lxc.cap.drop: 
lxc.cgroup.devices.allow: a
lxc.mount.auto: proc:rw sys:rw
EOL
        
    done
done

rm -f template-ubuntu-22.04.tar.zst