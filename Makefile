INSTANCE_NAME = multipass-dev
SSH_KEY_NAME = id_ed25519

multipass:
	multipass launch docker -n $(INSTANCE_NAME) -m 8g -c 4 -d 40gb
	multipass set client.primary-name=$(INSTANCE_NAME)
	multipass transfer ~/.ssh/$(SSH_KEY_NAME).pub $(INSTANCE_NAME):/home/ubuntu/.ssh/$(SSH_KEY_NAME).pub
	multipass transfer ~/.ssh/$(SSH_KEY_NAME) $(INSTANCE_NAME):/home/ubuntu/.ssh/$(SSH_KEY_NAME)
	multipass exec $(INSTANCE_NAME) -- sh -c 'cat /home/ubuntu/.ssh/$(SSH_KEY_NAME).pub >> /home/ubuntu/.ssh/authorized_keys'
	make save-ssh-config

setup:
	multipass exec $(INSTANCE_NAME) -- sudo apt-get update
	multipass exec $(INSTANCE_NAME) -- sudo apt-get install -y git build-essential zsh curl wget ca-certificates
	multipass exec $(INSTANCE_NAME) -- sudo snap install go --classic
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

repo:
	multipass exec $(INSTANCE_NAME) -- mkdir /home/ubuntu/repos
	multipass exec $(INSTANCE_NAME) -- git clone git@github.com:andrewsokolov/scylla-project.git /home/ubuntu/repos/scylla-project

local:
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "cd /home/ubuntu/repos/scylla-project && make local"

save-ssh-config:
	@LOCAL_IP=$$(multipass info $(INSTANCE_NAME) --format csv | awk -F"," 'NR>1 {print $$3}'); \
    if ! grep -q "Host $(INSTANCE_NAME)" ~/.ssh/config; then \
        echo "Host $(INSTANCE_NAME)\n  HostName $$LOCAL_IP\n  User ubuntu" >> ~/.ssh/config; \
    fi