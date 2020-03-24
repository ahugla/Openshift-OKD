#  install OKS 3.11
#  ----------------
#
#  https://github.com/openshift/openshift-ansible/tree/release-3.11
#  https://www.youtube.com/watch?v=vP3GqfcaVSI
#
#  tested avec :   4 vCPU - 16Go RAM - 32Go HD
#
#  Useful:
#    oc cluster up --help
#    https://[VM]:8443/console  login/pass : admin/12345
#    To login as administrator:  oc login -u system:admin


# Parameters
my_domain=cpod-vrealizesuite.az-demo.shwrfr.com


# ENABLE SELINUX
setenforce 0    # Set to permissive mode        setenforce 1 = Set to enforcing mode.
sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=permissive/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux

# install prerequisites
yum install -y ansible pyOpenSSL python-cryptography python-lxml git


# git config
cd /opt
git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible
#git branch -a   =>  voir toutes les branches
git checkout remotes/origin/release-3.11


# replace 'localhost' by the FQDN in the inventory file
my_fqdn=$HOSTNAME.$my_domain
#echo $my_fqdn
sed -i -e 's/localhost/'"$my_fqdn"'/g'  /opt/openshift-ansible/inventory/hosts.localhost


# run playbooks
sudo ansible-playbook -i inventory/hosts.localhost playbooks/prerequisites.yml
sudo ansible-playbook -i inventory/hosts.localhost playbooks/deploy_cluster.yml


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
systemctl restart docker


oc cluster up --public-hostname=$HOSTNAME

# INDISPENSABLE pour donner les droits à "admin" d'acceder a Openshift depuis CAS (via API)
#oc adm policy add-cluster-role-to-user cluster-admin admin --rolebinding-name=cluster-admins


#  https://IP:8443/console
#  ex : https://vra-000765.cpod-vrealizesuite.az-demo.shwrfr.com:8443/console/catalog


