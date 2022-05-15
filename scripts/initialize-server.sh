#!/bin/bash

MINECRAFT_SERVER_JAR_URL="https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar"

install_java() {
    wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
    tar xvf openjdk-17.0.2_linux-x64_bin.tar.gz
    sudo mv jdk-17.0.2/ /opt/jdk-17/
    echo 'export JAVA_HOME=/opt/jdk-17' | sudo tee /etc/profile.d/java17.sh
    echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/java17.sh
    source /etc/profile.d/java17.sh
    java --version
}

install_minecraft_server() {
    wget $MINECRAFT_SERVER_JAR_URL
    chmod +x server.jar
    mkdir -p /opt/minecraft/modded
    mv server.jar /opt/minecraft/modded
    pushd /opt/minecraft/modded
    echo "eula=true"
}

setup_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable minecraft@modded
    sudo systemctl start minecraft@modded

}

install() {
    install_java
    sudo apt install screen -y
    install_minecraft_server
    setup_service
}

install
