variable "account_id" {
  type = string
  default = "126591649419"
}

variable "access_key_id" {
    type = string
    default = "GSFVQOFX29Z4WT0HAWUS"
}
variable "secret_key_id" {
    type = string
    default = "25UMA3VKDTH762C6GXIT1TBGOQ0TIJ3C89MGYP32"
}

variable "region" {
    type = string
    default = "eu-west-2"
}

variable "image_id" {
    type = string
    default = "ami-4779e795" # Ubuntu-20.04-2021.09.09-0 on eu-west-2
}
variable "vm_type" {
    type = string
    default = "tinav4.c1r1p2"
}
