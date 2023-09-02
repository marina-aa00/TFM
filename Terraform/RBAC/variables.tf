//Sensitive fields - avoid harcoded values
variable "principal_user_id" {
  description = "Id of user in Azure AD"
  type = string
}

variable "resource_group_id" {
    description  = "Id of the resource group"
    type = string
}