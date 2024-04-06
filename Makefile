
multipass:
	multipass launch docker -n multipass-dev -m 8g -c 4 -d 40gb --cloud-init ./cloud-init.yaml -v
	multipass mount ~/.ssh multipass-dev:/mnt/ssh
	multipass set client.primary-name=multipass-dev