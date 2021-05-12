variable "create" {
  type = bool
  default = true
}
variable "web_acl_name" {
  type = string
}
variable "description" {
  type = string
  default = null
}
variable "scope" {
  type = string
  default = null
}
variable "default_webacl_action" {
  type = bool
  default = true
}
variable "managed_rule_group" {
  type = any
  default = []
}
variable "rate_based" {
  type = any
  default = []
}
variable "visibility_config" {
  type = any
  default = []
}
variable "default_tags" {
  type = map(string)
  default = {}
}
variable "excluded_rule" {
  type = any
  default = []
}
variable "aggregate_key_type" {
  type = any
  default = []
}
variable "resource_association" {
  type = any
  default = {}
}