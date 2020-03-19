#  Install OKD 3.11
#
#  based on:  https://computingforgeeks.com/setup-openshift-origin-local-cluster-on-centos/
#
#  tested avec :   4 vCPU - 16Go RAM - 32Go HD
#
#  Useful:
#    oc cluster up --help
#    https://[VM]:8443/console  login/pass : admin/12345
#    To login as administrator:  oc login -u system:admin


cd /opt


# yum -y update
yum install -y wget


# Install and configure docker

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y  docker-ce docker-ce-cli containerd.io


# Inutile 
# Add your standard user account to docker group
#usermod -aG docker $USER
#newgrp docker  # permet de changer l'identifiant de groupe de l'utilisateur au cours de session


# Configure the Docker daemon with an insecure registry parameter of 172.30.0.0/16
mkdir /etc/docker /etc/containers
tee /etc/containers/registries.conf<<EOF
[registries.insecure]
registries = ['172.30.0.0/16']
EOF
tee /etc/docker/daemon.json<<EOF
{
   "insecure-registries": [
     "172.30.0.0/16"
   ]
}
EOF


# Need to reload systemd and restart the Docker daemon after editing the config
systemctl daemon-reload
systemctl restart docker


#Enable Docker to start at boot
systemctl enable docker


# Enable IP forwarding on your system
echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
sysctl -p


# useless as firewall is disable in the template
# Ensure that your firewall allows containers access to the OpenShift master API (8443/tcp) and DNS (53/udp) endpoints.
# DOCKER_BRIDGE=`docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge`
# firewall-cmd --permanent --new-zone dockerc
# firewall-cmd --permanent --zone dockerc --add-source $DOCKER_BRIDGE
# firewall-cmd --permanent --zone dockerc --add-port={80,443,8443}/tcp
# firewall-cmd --permanent --zone dockerc --add-port={53,8053}/udp
# firewall-cmd --reload


# Download the Linux oc binary from openshift-origin-client-tools-VERSION-linux-64bit.tar.gz and place it in your path.
wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar xvf openshift-origin-client-tools*.tar.gz
cd openshift-origin-client*/
mv  oc kubectl  /usr/local/bin/

# Verify version of OpenShift client utility
oc version


# By default, this OpenShift environment was configured to listen on the loopback interface (127.0.0.1). 
# This means that you may connect to the cluster using https://127.0.0.1:8443. 
# This behavior can be changed by adding special parameters, such as --public-hostname=
# A public hostname can also be specified for the server with the --public-hostname flag.
oc cluster up --public-hostname=$HOSTNAME


# On remplace dans le fichier kubeconfig  127.0.0.1 par l'ip de la VM
my_ip=$(hostname  -I | cut -f1 -d' ')
configfile="/opt/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/openshift.local.clusterup/openshift-controller-manager/openshift-master.kubeconfig"
sed -i -e 's/server: https:\/\/127.0.0.1:8443/server: https:\/\/'"$my_ip"':8443/g'  $configfile


# config reload
kubectl config use-context myproject/127-0-0-1:8443/developer





