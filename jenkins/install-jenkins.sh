#!/bin/bash
# Instalação do OpenJDK 11 + Jenkins
# Por Alan Queiroz - alan.queiroz@cronapp.io
# Em 20/09/2020

# Atualizando lista de repositórios 
sudo apt update -y

# Instalando pacotes essenciais
apt-get install wget unzip git -y

# Instalando o OpenJDK-11
apt-get install openjdk-11-jdk -y
echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/" >> /etc/environment
source /etc/environment

# Adicionando chave e repositório do Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Buscando novas atualizações de repositórios
sudo apt update -y

# Instalando o Jenkins
sudo apt install jenkins -y

# Iniciando o Jenkins
sudo systemctl start jenkins 

# Habilitando o Jenkins na inicialização do S.O
sudo systemctl enable jenkins

sleep 10
# Obtendo a senha inicial do usuário [Admin] do Jenkins
echo "Senha temporária do usuário admin do Jenkins:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword