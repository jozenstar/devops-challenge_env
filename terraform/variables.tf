variable "aws" {
  type = map
  default = {
    region : "eu-central-1"
    profile : "default"
  }
}
variable "ssh_public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgkXA+/vlmPPkpP9msz3MYwjeVCxtWnypfF38Avz/5GWYTG5VXGd1ko8zS8+BN4NxqFip0OkNzugqxzQka9yRsXBykTWV2qWPaNI//kST8dUzHQTzyt+HUgJySWQRRmPA3gBiMR++NKSufE6A7Mofl3hz71Gw2zuDk0kh0Xnp5enRMlyy2jgTb7aeBOGF79upNUI+/GATJLPPTlS34wXMpwl7ycFGXRxv7YjjLXWp+3mXsJnq1+6XRc5uGuSWzglUE7NVcIwurHsNl6CH0j0OXEI5VE53k/IF7HdTKVR0WtIoVtziGhASFpq5iS7eAWmRtiwtOTLB7bxvuMrAc0yC7 arthur.yazhevich@gmail.com"
}
