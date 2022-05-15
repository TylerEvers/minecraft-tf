#!/bin/bash
GCE_INSTANCE="${1:-minecraft-one-eighteen-server}"

run_terraform() {
    pushd terraform
    terraform init -input=false
    terraform apply -input=false -auto-approve
    popd
}

move_files() {
   gcloud compute scp "scripts/minecraft@.service" $GCE_INSTANCE:~/
   gcloud compute ssh $GCE_INSTANCE -- sudo mv 'minecraft@.service' /etc/systemd/system
   gcloud compute ssh $GCE_INSTANCE -- sudo mkdir -p /opt/minecraft/modded
   gcloud compute ssh $GCE_INSTANCE -- sudo chmod -R 777 /opt/minecraft/modded
   gcloud compute scp scripts/ops.json $GCE_INSTANCE:/opt/minecraft/modded/
   gcloud compute scp scripts/server.properties $GCE_INSTANCE:/opt/minecraft/modded/
   gcloud compute scp scripts/start.sh $GCE_INSTANCE:/opt/minecraft/modded/
   gcloud compute scp scripts/regenWorld.sh $GCE_INSTANCE:/opt/minecraft/modded/
   gcloud compute scp scripts/updateMods.sh $GCE_INSTANCE:/opt/minecraft/modded/
   gcloud compute scp scripts/initialize-server.sh  $GCE_INSTANCE:~/
}

run_terraform
move_files
gcloud compute ssh $GCE_INSTANCE -- bash initialize-server.sh
