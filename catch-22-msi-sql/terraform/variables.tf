
# set externally
variable "environment_name" { type = string }
variable "database_name" { type = string }

# set in values.auto.tfvars
variable "resource_location" { type = string }
variable "tags" { type = map }
