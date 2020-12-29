# wait for 
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

# sudo apt --fix-broken install
# sudo apt-get upgrade -y
sudo apt-get update -y

# install java jdk
sudo apt-get install -y default-jdk