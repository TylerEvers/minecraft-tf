#!/bin/bash -x

MODPACK_URL="https://storage.googleapis.com/minecraft-modpack-1-18-2/modpack.zip"
MINECRAFT_FOLDER=/opt/minecraft/modded
DOWNLOAD_FOLDER=$MINECRAFT_FOLDER/scratch
MOD_FOLDER=$MINECRAFT_FOLDER/mods
SERVICE_NAME=minecraft@modded
MODPACK_NAME="Jolley1.16.5 mods"
WORLD_FOLDER=$MINECRAFT_FOLDER/world

service $SERVICE_NAME stop
mkdir -p $DOWNLOAD_FOLDER
rm -rf $DOWNLOAD_FOLDER/*
rm -rf $MOD_FOLDER
# rm -rf $WORLD_FOLDER

curl $MODPACK_URL --output "$DOWNLOAD_FOLDER/$MODPACK_NAME.zip"
unzip -o -q "$DOWNLOAD_FOLDER/$MODPACK_NAME.zip" -d "$DOWNLOAD_FOLDER"
mv -f "$DOWNLOAD_FOLDER/$MODPACK_NAME/.minecraft/mods" $MOD_FOLDER
chown -R minecraft:minecraft $MOD_FOLDER
service $SERVICE_NAME start
