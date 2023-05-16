.PHONY: init
init:
	terraform init

.PHONY: plan
plan-%:
	terraform plan -var-file=env/$*/vars.tfvars

.PHONY: apply
apply-%:
	terraform apply -auto-approve -var-file=env/$*/vars.tfvars

.PHONY: destroy
destroy-%:
	terraform destroy -var-file=env/$*/vars.tfvars