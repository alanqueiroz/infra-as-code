# Instalação do Postgresql 12
# Criado 02/09/2020 - Versão 1.0
# Por: Alan Queiroz - alanqueiroz@outlook.com

SENHA_USR_SONAR=""

# Criando diretório para o postgres
mkdir /var/lib/postgresql

# Adicionar repostitório Postgres
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list

# Atualizar lista de repositórios
apt-get update

# Instalando Postgres
apt -y install postgresql-12 postgresql-client-12

# Inicilizando serviço do postgres
systemctl start postgresql

# Habilitar inicialização automática no boot do S.O 
systemctl enable postgresql

echo "Informe uma senha para o usuário [usr_sonar] no banco"
read -s SENHA_USR_SONAR

cat > sonar.sql << EOF
-- Criar usuário sonar
create user usr_sonar;

-- Alterar senha do usuário usr_sonar
ALTER USER usr_sonar WITH ENCRYPTED password '$SENHA_USR_SONAR';

-- Criar nova base "sonarqube"
CREATE DATABASE sonarqube OWNER usr_sonar;

-- Atribuir permissão total do usuário usr_sonar ao banco sonarqube
grant all privileges on DATABASE sonarqube to usr_sonar;
EOF

su - postgres -c 'psql -U postgres' < sonar.sql 

sleep 10

rm -rf sonar.sql