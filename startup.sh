#!/bin/bash

HOSTNAME=""
ANSIBLE_VARS_FILE=""
CONSUL_MASTER_IP=""
VAULT_SERVER_IP=""
SSH_KEY_FINGERPRINT=""

TYPE="aws"
CONF_DIR="terraform"
MACHINE_PATH="stores"
WORK_DIR=""
FORCE_CREATE=false
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
    echo ""
    echo "${0} --host <hostname>"
    echo ""

    return
}

generate_ssh_keys() {
	echo "[INFO] Generating new ssh keys."
	if [ -f "id_rsa" ] && [ -f "id_rsa.pub" ] ; then
   		echo "[INFO] Your keys already exist."
   	else
   		rm -f id_rsa
   		rm -f id_rsa.pub
		ssh-keygen -t rsa -N "" -f id_rsa
	fi

    return
}

get_ssh_fingerprint() {
	echo "[INFO] SSH key fingerprint capture."
	if [ ! -f "id_rsa.pub" ] ; then
   		echo "[ERROR] No 'id_rsa.pub' in the folder."
   		exit 1
   	else
		SSH_KEY_FINGERPRINT=$(ssh-keygen -lf id_rsa.pub | awk '{print $2}')
	fi

    return
}

create_tfvars_file() {
	if [ -f "terraform.tfvars" ]; then
	    rm -f terraform.tfvars
	fi
	echo "[INFO] Creating 'terraform.tfvars'."
	touch terraform.tfvars

	echo "hostname = \"$HOSTNAME\"" >> terraform.tfvars

    if [ "$TYPE" == "digitalocean" ]; then
	   echo "ssh_fingerprint = \"$SSH_KEY_FINGERPRINT\"" >> terraform.tfvars
    fi

    if [[ ! -z "$ANSIBLE_VARS_FILE" ]]; then
        echo "ansible_vars_file = \"$ANSIBLE_VARS_FILE\"" >> terraform.tfvars
    fi

    if [[ ! -z "$CONSUL_MASTER_IP" ]]; then
        echo "consul_master_ip = \"$CONSUL_MASTER_IP\"" >> terraform.tfvars
    fi

    if [[ ! -z "$VAULT_SERVER_IP" ]]; then
        echo "vault_server_ip = \"$VAULT_SERVER_IP\"" >> terraform.tfvars
    fi

	echo ""
	echo "[INFO] File 'terraform.tfvars' is created."
	echo "[INFO] Use it for further manipulation of your machine."
	echo "[INFO] Like: $ terraform destroy -var-file='terraform.tfvars'"
	echo ""
    return
}

prepare_machine_workplace() {
	if [ ! -d "$CONF_DIR" ] || [ ! "$(ls -A $CONF_DIR)" ]; then
	  	echo "[ERROR] Bad 'conf_dir' path"
   		exit
	fi

    WORK_DIR=$MACHINE_PATH/$HOSTNAME

    if [ -d "$WORK_DIR" ]; then
        if [ "$FORCE_CREATE" == false ]; then
            echo "[ERROR] Path '$WORK_DIR' already exists."
            exit
        fi

        if [ -f "$WORK_DIR/terraform.tfstate" ]; then
            cd $WORK_DIR

            echo "[INFO] Destroy current machine."
            echo yes | terraform destroy
        fi

        cd $BASEDIR
        rm -rf $WORK_DIR
    fi    

	mkdir -p $WORK_DIR
	cp -r $CONF_DIR/* $WORK_DIR
    cd $WORK_DIR

	return
}

while [[ $# > 1 ]]
do
key="$1"
case $key in
    -h|--host)
    HOSTNAME=$(echo "$2" | awk '{print tolower($0)}')
    shift
    ;;
    -a|--ansible_vars_file)
    ANSIBLE_VARS_FILE=$(echo "$2" | awk '{print tolower($0)}')
    shift
    ;;
    -d|--conf_dir)
    CONF_DIR=$(echo "$2" | awk '{print tolower($0)}')
    shift
    ;;
    -p|--machine_path)
    MACHINE_PATH=$(echo "$2" | awk '{print tolower($0)}')
    shift
    ;;
    -m|--consul_master_ip)
    CONSUL_MASTER_IP=$(echo "$2" | awk '{print tolower($0)}')
    shift
    ;;
    -v|--vault_server_ip)
    VAULT_SERVER_IP=$(echo "$2" | awk '{print tolower($0)}')
    shift
    ;;
    -f|--force)
    FORCE_CREATE=true
    shift
    ;;
    -t|--type)
    TYPE=$(echo "$2" | awk '{print tolower($0)}')
    shift
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)    
    ;;
esac
shift
done

if [[ -z "$HOSTNAME" ]]; then
    usage
    exit
fi

CONF_DIR="$CONF_DIR/$TYPE"
# Create machine folder and copy conf files.
prepare_machine_workplace

# Generate public/private rsa key pair.
generate_ssh_keys

# Get ssh public key fingerprint.
get_ssh_fingerprint

if [[ -z "$SSH_KEY_FINGERPRINT" ]] ;
then
    echo "[ERROR] An error occurred while taking the ssh key fingerprint."
    exit
else
	echo "[INFO] SSH key fingerprint: $SSH_KEY_FINGERPRINT "
fi

# Create 'terraform.tfvars' for further convenience. 
# $ terraform plan -var-file="terraform.tfvars" ...
create_tfvars_file

#####
terraform plan
terraform apply 