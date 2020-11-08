# Script de instalação do SonarQube-Community 7.9.4
# Criado 02/09/2020 - Versão 1.0
# Por: Alan Queiroz - alanqueiroz@outlook.com

SENHA_LDAP=""
USUARIO_DB_SONAR=""
SENHA_USR_SONAR=""
IP_LDAP=""
IP_SERVIDOR_POSTGRES=""
URL_SONARQUBE=""
BACKUP_SONAR="/home/ubuntu/sonarqube"

# Adicionar ao sysctl
mkdir -p $BACKUP_SONAR
cp /etc/sysctl.conf $BACKUP_SONAR
echo "vm.max_map_count=262145" >> /etc/sysctl.conf
echo "fs.file-max=65536" >> /etc/sysctl.conf

# Executar as mudanças do sysctl.conf sem precisar reiniciar o S.O
sysctl -p

# Instalação de pacotes essenciais
apt-get update -y
apt-get install wget unzip git -y

# Instalar Java
apt-get install openjdk-11-jdk -y
echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/" >> /etc/environment
source /etc/environment

# Diretório para guardar uma cópia do sonarqube
cd /home/ubuntu/sonarqube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.9.4.zip

# Extrair pacote sonarqube 
unzip sonarqube-7.9.4.zip
mv sonarqube-7.9.4 /opt/sonarqube

# Criar grupo e usuário sonar
groupadd sonar

# Usuário para executar o sonarqube
useradd -c "usuário para executar o SonarQube" -d /opt/sonarqube -g sonar sonar 
chown sonar:sonar /opt/sonarqube -R
# Caminho dos logs do sonarqube
mkdir /var/log/sonar
chown sonar:sonar /var/log/sonar -R

echo "Informe o IP do servidor do LDAP"
read IP_LDAP

echo "Informe a senha do usuário [svc.sonar] criada no LDAP e pressione [ENTER]"
read -s SENHA_LDAP

echo "Informe o IP do servidor do postgres"
read IP_SERVIDOR_POSTGRES

echo "Informe o usuário do banco do sonar e pressione [ENTER]"
read USUARIO_DB_SONAR

echo "Informe a senha do usuário do banco do sonar e pressione [ENTER]"
read -s SENHA_USR_SONAR

cat > /opt/sonarqube/conf/sonar.properties << EOF
#### CONFIGURANDO O SONARQUBE  ####
# Credenciais de acesso a base do sonarqube
sonar.jdbc.username=$USUARIO_DB_SONAR
sonar.jdbc.password=$SENHA_USR_SONAR
sonar.web.host=127.0.0.1
# Conexão com o banco do sonarqube
sonar.jdbc.url=jdbc:postgresql://$IP_SERVIDOR_POSTGRES:5432/sonarqube
# Permite que o sonar escute em todas as interfaces de rede
sonar.web.host=0.0.0.0
# Especifando a porta do sonarqube
sonar.web.port=9002
# Definindo a memória do Java para o Elasticsearch
sonar.search.javaOpts=-Xms1024m -Xmx1024m -XX:+HeapDumpOnOutOfMemoryError
# Definindo o caminho, tamanho e quantidade dos logs
sonar.path.logs=/var/log/sonar
sonar.log.rollingPolicy=size:20MB
sonar.log.maxFiles=7

### CONFIGURAÇÕES LDAP ###

# CONFIGURAÇÕES GLOBAL #
sonar.security.realm=LDAP
ldap.url=ldap://$IP_LDAP:389
ldap.bindDn=svc.sonarqube@techroute.com.br
ldap.bindPassword=$SENHA_LDAP
ldap.authentication=simple

# CONFIGURAÇÕES DE USUÁRIOS #
ldap.user.baseDn=OU=USERS_SSA,OU=USERS_TECHROUTE,OU=USERS,OU=TECHROUTE,DC=techroute,DC=com,DC=br
ldap.user.request=(&(objectClass=user)(sAMAccountName={login}))

### FIM DAS CONFIGURAÇÕES DE LDAP ###
EOF

## Especificando o usuário que vai executar o sonarqube
sed -i -e 's/#RUN_AS_USER=/RUN_AS_USER=sonar/g' /opt/sonarqube/bin/linux-x86-64/sonar.sh

cat > /etc/systemd/system/sonar.service << EOF
##### Configuração para o sonar rodar como serviço #####
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
###################################################
EOF

systemctl daemon-reload

chown -R sonar:sonar /var/log/sonar/

## Inicie o sonarqube e habilite a inicialização automática no boot ##
systemctl start sonar 
systemctl enable sonar

## Instalação do nginx e configuração de vhost ##
apt-get install nginx -y
systemctl enable nginx
systemctl start nginx

echo "Informe a URL do sonarqube [Ex: sonarqube.cronapp.io]"
read URL_SONARQUBE

cat > /etc/nginx/sites-enabled/sonarqube.conf << EOF
server {
	listen 80;

	server_name $URL_SONARQUBE;
	access_log  /var/log/nginx/$URL_SONARQUBE.access.log;
    error_log  /var/log/nginx/$URL_SONARQUBE.error.log;
	
	location / {
	    proxy_pass http://localhost:9002;
	}
}
EOF

systemctl restart nginx

## Nota: Alterar a senha do usuário admin do sonarqube, instalar os plugins das linguagens desejada
# Forçar autenticação dos usuários no sonarqube
# -> Administration -> Configuration -> General Settings -> Security e habilitar o item "Force user authentication"