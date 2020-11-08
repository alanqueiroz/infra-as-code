# Script para instalar os plugins com base em uma lista [lista_plugins]
# Por Alan Queiroz - alanqueiroz@outlook.com
# Em 21/09/2020

USUARIO_JENKINS=""
SENHA_JENKINS=""
LISTA_PLUGINS="/home/ubuntu/lista_plugins"
URL_JENKINS="http://127.0.0.1:8080"
JENKINS_CLI="/home/ubuntu/jenkins-cli.jar"

if [ ! -f "$JENKINS_CLI" ]; then
   wget $URL_JENKINS/jnlpJars/jenkins-cli.jar
fi
echo "Informe o usuário do Jenkins"
read USUARIO_JENKINS

echo "Senha do usuário do Jenkins"
read -s SENHA_JENKINS

for I in `cat $LISTA_PLUGINS`; do
        java -jar jenkins-cli.jar -s $URL_JENKINS -auth $USUARIO_JENKINS:$SENHA_JENKINS install-plugin $I
done

systemctl restart jenkins