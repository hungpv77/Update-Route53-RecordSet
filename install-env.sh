#!/bin/bash
main(){
    install_util_tools
    install_aws_cli
    install_jq_lib
}

install_util_tools() {
    # Install basic tools
    echo "INFO: Installing basic tools..."
    apt-get -y install git unzip
}

install_aws_cli(){
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

    mkdir ~/.aws
    echo "Configuring " 
    echo "[default]
    aws_access_key_id = AKIAJ3TL62KOCDCT4GNQ
    aws_secret_access_key = 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" | sudo tee ~/.aws/credentials

    echo "[default]
    output = json
    region = us-east-1" | sudo tee ~/.aws/config

    sudo mkdir /root/.aws
    echo "Configuring " 
    echo "[default]
    aws_access_key_id = AKIAJ3TL62KOCDCT4GNQ
    aws_secret_access_key = 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" | sudo tee /root/.aws/credentials

    echo "[default]
    output = json
    region = us-east-1" | sudo tee root/.aws/config

}

install_jq_lib(){
    wget http://stedolan.github.io/jq/download/linux64/jq
    sudo chmod +x ./jq
    sudo cp jq /usr/bin
}

main
exit 0