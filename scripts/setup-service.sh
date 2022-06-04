setup_service() {
    sudo systemctl daemon-reload
    sudo systemctl enable minecraft@modded
    sudo systemctl start minecraft@modded
}

setup_service
