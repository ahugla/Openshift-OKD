#  install OKS 3.11
#  ----------------
#
#  https://github.com/openshift/openshift-ansible/tree/release-3.11
#  https://www.youtube.com/watch?v=vP3GqfcaVSI
#



# ENABLE SELINUX
setenforce 0    # Set to permissive mode        setenforce 1 = Set to enforcing mode.
sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=permissive/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux


yum install -y ansible pyOpenSSL python-cryptography python-lxml git


cd /opt
git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible
#git branch -a   =>  voir toutes les branches
git checkout remotes/origin/release-3.11


sudo ansible-playbook -i inventory/hosts.localhost playbooks/prerequisites.yml
sudo ansible-playbook -i inventory/hosts.localhost playbooks/deploy_cluster.yml


oc cluster up --public-hostname=$HOSTNAME

#  https://IP:8443/console
#  https://vra-000765.cpod-vrealizesuite.az-demo.shwrfr.com:8443/console/catalog