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
   gcloud compute scp scripts/setup-service.sh  $GCE_INSTANCE:~/
}

setup_server() {
    gcloud compute ssh $GCE_INSTANCE -- bash initialize-server.sh
    gcloud compute scp scripts/run.sh  $GCE_INSTANCE:/opt/minecraft/modded
    gcloud compute scp scripts/user_jvm_args.txt  $GCE_INSTANCE:/opt/minecraft/modded
    gcloud compute ssh $GCE_INSTANCE -- sudo chown -R minecraft:minecraft /opt/minecraft/
    gcloud compute ssh $GCE_INSTANCE -- bash setup-service.sh
}

run_terraform
move_files
setup_server
