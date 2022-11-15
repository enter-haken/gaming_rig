review:
	terraform init 
	terraform fmt -check
	terraform validate

docs:
	terraform-docs markdown table --output-file README.md --output-mode inject .
