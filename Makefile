INSTANCE_NAME = multipass-dev
SSH_KEY_NAME = id_ed25519
PROJECT_NAME = scylla-project

multipass:
	multipass launch docker -n $(INSTANCE_NAME) -m 8g -c 4 -d 40gb
	multipass set client.primary-name=$(INSTANCE_NAME)
	multipass transfer ~/.ssh/$(SSH_KEY_NAME).pub $(INSTANCE_NAME):/home/ubuntu/.ssh/$(SSH_KEY_NAME).pub
	multipass transfer ~/.ssh/$(SSH_KEY_NAME) $(INSTANCE_NAME):/home/ubuntu/.ssh/$(SSH_KEY_NAME)
	multipass exec $(INSTANCE_NAME) -- sh -c 'cat /home/ubuntu/.ssh/$(SSH_KEY_NAME).pub >> /home/ubuntu/.ssh/authorized_keys'
	make save-ssh-config

test:
	@echo test

setup:
	multipass exec $(INSTANCE_NAME) -- sudo apt-get update
	multipass exec $(INSTANCE_NAME) -- sudo apt-get install -y git build-essential zsh curl wget ca-certificates
	multipass exec $(INSTANCE_NAME) -- sudo snap install go --classic
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "echo 'source ~/.profile' >> /home/ubuntu/.zshrc"
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "echo 'cd ~/repos/$(PROJECT_NAME)' >> /home/ubuntu/.zshrc"
	make tools

tools:
	multipass exec $(INSTANCE_NAME) -- sudo apt install bat
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "mkdir -p ~/.local/bin"
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "ln -s /usr/bin/batcat /home/ubuntu/.local/bin/bat"

repo:
	multipass exec $(INSTANCE_NAME) -- git config --global user.name "Andrew Sokolov"
	multipass exec $(INSTANCE_NAME) -- git config --global user.email "mr.andrewsokolov@gmail.com"
	multipass exec $(INSTANCE_NAME) -- mkdir /home/ubuntu/repos
	multipass exec $(INSTANCE_NAME) -- git clone git@github.com:andrewsokolov/$(PROJECT_NAME).git /home/ubuntu/repos/$(PROJECT_NAME)

local:
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "cd /home/ubuntu/repos/$(PROJECT_NAME) && make local"

local-stop:
	multipass exec $(INSTANCE_NAME) -- /bin/zsh -c "cd /home/ubuntu/repos/$(PROJECT_NAME) && make stop"

save-ssh-config:
	@LOCAL_IP=$$(multipass info $(INSTANCE_NAME) --format csv | awk -F"," 'NR>1 {print $$3}'); \
    if ! grep -q "Host $(INSTANCE_NAME)" ~/.ssh/config; then \
        echo "Host $(INSTANCE_NAME)\n  HostName $$LOCAL_IP\n  User ubuntu" >> ~/.ssh/config; \
    fi