terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.34.1"
    }
  }
}

variable "do_token" {
  type      = string
  sensitive = true
}

provider "digitalocean" {
  token = var.do_token
}
