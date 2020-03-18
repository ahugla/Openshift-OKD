#  Install OKD
#
#  based on:  https://computingforgeeks.com/setup-openshift-origin-local-cluster-on-centos/
#
#  tested avec :   4 vCPU - 16Go RAM - 32Go HD




cd /opt

#systemctl start firewalld


yum -y update
yum install -y wget


# Install and configure docker

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y  docker-ce docker-ce-cli containerd.io


# Add your standard user account to docker group
usermod -aG docker $USER
newgrp docker  # permet de changer l'identifiant de groupe de l'utilisateur au cours de session


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
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
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


# By default, the OpenShift cluster will be setup to use a routing suffix that ends in nip.io.
# This is to allow dynamic host names to be created for routes. An alternate routing suffix can be specified using the --routing-suffix flag.

# By default, this OpenShift environment was configured to listen on the loopback interface (127.0.0.1). 
# This means that you may connect to the cluster using https://127.0.0.1:8443. 
# This behavior can be changed by adding special parameters, such as --public-hostname=
# A public hostname can also be specified for the server with the --public-hostname flag.

##oc cluster up --public-hostname=vra-000739.cpod-vrealizesuite.az-demo.shwrfr.com --routing-suffix='cpod-vrealizesuite.az-demo.shwrfr.com'
##oc cluster up --public-hostname=vra-000739.cpod-vrealizesuite.az-demo.shwrfr.com --routing-suffix='services.cpod-vrealizesuite.az-demo.shwrfr.com'

# Bootstrap a local single server OpenShift Origin cluster 
#    Start OKD Cluster listening on the local interface – 127.0.0.1:8443
#    Start a web console listening on all interfaces at /console (127.0.0.1:8443).
#    Launch Kubernetes system components.
#    Provisions registry, router, initial templates, and a default project.
#    The OpenShift cluster will run as an all-in-one container on a Docker host.
# 
# oc cluster up --public-hostname=okd.example.com --routing-suffix='services.example.com'
# oc cluster up --public-hostname=vra-000739.cpod-vrealizesuite.az-demo.shwrfr.com --routing-suffix='vra-000739.cpod-vrealizesuite.az-demo.shwrfr.com'



# xip.io is a magic domain name that provides wildcard DNS for any IP address.
#  =>  https://okd.example.com:8443/console/
# The OpenShift Origin cluster configuration files will be located inside the 'openshift.local.clusterup/' directory.


# Useful
#    oc cluster up --help
#    oc cluster up 
#	 oc cluster down
#    https://127.0.0.1:8443
#    To login as administrator:  oc login -u system:admin
#    The OpenShift Origin cluster configuration files will be located inside the 'openshift.local.clusterup/' directory.






# DO NO KEEP
# ---------
#
# https://raw.githubusercontent.com/ahugla/Openshift-OKD/master/script-install-OKD-3.11.sh

# https://vra-000739.cpod-vrealizesuite.az-demo.shwrfr.com:8443
# https://172.19.2.215:8443