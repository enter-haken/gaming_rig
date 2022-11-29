.PHONY: venv, build, init, clean
.ONESHELL:

build: init build/variables.tf
	chalice package --pkg-format terraform --stage prod ./build
	echo $$(jq 'del(.terraform)' ./build/chalice.tf.json) > ./build/chalice.tf.json

venv:
	[ -d ./venv ] || python3 -m venv venv
	. venv/bin/activate

init: venv
	python3 -m pip install -r ./requirements.txt

clean:
	rm ./venv/ -rf
	rm ./__pycache__/ -rf
	rm ./build/ -rf

build/variables.tf:
	mkdir -p ./build
	cat <<- EOF > $@
	variable "app_tag" {
	  description = "application tag"
	  default     = "gaming-rig"
	}
	
	variable "rig_ami_name" {
	  description = "ami_name"
	  default     = "gaming-rig"
	}
	
	variable "rig_ami_root_ebs_size" {
	  description = "Size of the root_ebs_volume of the image."
	  default     = 256
	}
	EOF
	terraform fmt ./build/variables.tf
