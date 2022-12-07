.PHONY: start, up, down, debug, password, config, connect, wait_for_dcv_ready

start: up config wait_for_dcv_ready
	dcvviewer config.dcv

up:
	terraform apply -auto-approve

down:
	terraform destroy -auto-approve

debug:
	TF_LOG=DEBUG terraform apply -no-color -auto-approve > debug.log 2>&1

password:
	./get_initial_password.sh

config:
	./create_nice_dcv_config_file.sh

wait_for_dcv_ready:
	nc -w 600 -z $$(terraform output -json gaming-rig | jq -r '.instance_ip') 8443 || true

connect:
	dcvviewer config.dcv
