#!/bin/sh

PREMPTED=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/preempted" \
                -H " Metadata-Flavor: Google")

if [$PREMPTED = "TRUE"]; then
    /usr/bin/screen -p 0 -S mc-vanilla -X eval 'stuff "say This minecraft server instance is b
eing prempted by Google. It will be automatically restarted as soon as possible.  If it has
not restarted in 10 minutes, manually restart.  Sorry for the inconvenience"\015'
else
    /usr/bin/screen -p 0 -S mc-vanilla -X eval 'stuff "say The server is shutting down!"\015'
fi

service minecraft@vanilla stop
wall "Shutting down the instance"
