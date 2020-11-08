#!/bin/bash
# Por Alan Queiroz - alanqueiroz@outlook.com - 07/10/2020
# Script para listar os plugins instalados no jenkins

HOME="/home/ubuntu"
USUARIO_JENKINS=""
SENHA_JENKINS=""
PLUGINS_INSTALADOS="$HOME/lista_plugins_instalados.txt"
URL_JENKINS="http://127.0.0.1:8080"
JENKINS_CLI="$HOME/jenkins-cli.jar"
PLUGINS_GROOVY="$HOME/plugins.groovy"

# BAIXA O jenkins-cli.jar SE NÃO EXISTIR NO DIRETÓRIO
if [ ! -f "$JENKINS_CLI" ]; then
   wget $URL_JENKINS/jnlpJars/jenkins-cli.jar
fi

echo "Informe o usuário do Jenkins"
read USUARIO_JENKINS

echo "Senha do usuário do Jenkins"
read -s SENHA_JENKINS

# BUSCA PELOS PLUGINS INSTALADOS NO JENKINS, PASSANDO O SCRIPT GROOVY 
java -jar $JENKINS_CLI -s $URL_JENKINS -auth $USUARIO_JENKINS:$SENHA_JENKINS groovy = < $PLUGINS_GROOVY > $PLUGINS_INSTALADOS