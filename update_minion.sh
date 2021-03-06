if [ -z "$1" ]
  then
    echo "No minion supplied"
    exit
fi

ETCD_DISCVERY="10.91.11.202"
ADDR=$(ip addr | awk '/inet/ && /eth0/{sub(/\/.*$/,"",$2); print $2}')
MINION_IP_ADDRS=$(cat /usr/lib/systemd/system/kube-controller-manager.service | grep machines | sed -e 's/.*machines=\(.*\)-log.*/\1/' | sed -e 's/ //g' )",$1"
sudo mount -o remount,rw /dev/mapper/atomicos-root /usr/

cat <<EOF > /usr/lib/systemd/system/kube-controller-manager.service
[Unit]
ConditionFileIsExecutable=/usr/bin/kube-controller-manager
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
Wants=etcd.service
After=etcd.service

[Service]
ExecStart=/usr/bin/kube-controller-manager \
  -master=127.0.0.1:8080 \
  -machines=${MINION_IP_ADDRS} \
  -logtostderr=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable kube-controller-manager.service
systemctl restart kube-controller-manager.service
systemctl status kube-controller-manager.service