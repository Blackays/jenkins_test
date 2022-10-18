terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {

}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-22-04-x64"
  name   = "terraform_jenkins"
  region = "fra1"
  ssh_keys = ["jenkins droplet"]
  size   = "s-1vcpu-1gb"
  user_data = file("./user_data.sh")

  tags = ["jenkins_terraform","test"]
}
output "droplet_ipv4" {
    value = digitalocean_droplet.web.ipv4_address
}