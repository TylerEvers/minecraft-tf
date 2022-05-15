#!/bin/bash -x

SERVICE=minecraft@modded
MINECRAFT_FOLDER=/opt/minecraft/modded

service $SERVICE stop
rm -rf $MINECRAFT_FOLDER/world
service $SERVICE start
