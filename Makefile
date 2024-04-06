
multipass:
	multipass launch docker -n multipass-dev -m 8g -c 4 -d 40gb
	multipass set client.primary-name=multipass-dev
	multipass transfer ~/.ssh/id_ed25519.pub multipass-dev:/home/ubuntu/.ssh/id_ed25519.pub
	multipass transfer ~/.ssh/id_ed25519 multipass-dev:/home/ubuntu/.ssh/id_ed25519
	multipass exec multipass-dev -- sh -c 'cat /home/ubuntu/.ssh/id_ed25519.pub >> /home/ubuntu/.ssh/authorized_keys'

setup:
	multipass exec multipass-dev -- sudo apt-get update
	multipass exec multipass-dev -- sudo apt-get install -y git build-essential zsh curl wget ca-certificates
	multipass exec multipass-dev -- sudo snap install go --classic
	multipass exec multipass-dev -- /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

repo:
	multipass exec multipass-dev -- mkdir /home/ubuntu/repos
	multipass exec multipass-dev -- git clone git@github.com:andrewsokolov/scylla-project.git /home/ubuntu/repos/scylla-project

local:
	multipass exec multipass-dev -- /bin/zsh -c "cd /home/ubuntu/repos/scylla-project && make local"
