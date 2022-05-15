#!/bin/bash
if ! grep -q "eula=true" eula.txt; then
    echo "Do you agree to the Mojang EULA available at https://account.mojang.com/documents/minecraft_eula ?"
    read  -n 1 -p "[y/n] " EULA
    if [ "$EULA" = "y" ]; then
        echo "eula=true" > eula.txt
        echo
    fi
fi
/usr/lib/jvm/java-8-openjdk-amd64/bin/java -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -Xmx28G -Xms10G -Xss4M -jar server.jar nogui
