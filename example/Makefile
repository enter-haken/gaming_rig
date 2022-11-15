up:
	terraform apply -auto-approve

down:
	terraform destroy -auto-approve

debug:
	TF_LOG=DEBUG terraform apply -no-color -auto-approve > debug.log 2>&1

config:
	./create_nice_dcv_config_file.sh

connect:
	dcvviewer config.dcv
