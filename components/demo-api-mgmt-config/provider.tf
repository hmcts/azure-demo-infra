provider "azurerm" {
  version = "=1.36"
}

provider "template" {
  version = "=2.1"
}

terraform {
  backend "azurerm" {}
}
