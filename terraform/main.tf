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
  image     = "ubuntu-22-04-x64"
  name      = "terraformjenkins"
  region    = "fra1"
  size      = "s-1vcpu-1gb"
  user_data = file("./user_data.sh")
  ssh_keys = ["36483389"]

  tags = ["jenkins_terraform"]
}
output "droplet_ipv4" {
    value = digitalocean_droplet.web.ipv4_address
}