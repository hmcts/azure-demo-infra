provider "azurerm" {
  version = "=1.33.1"
}

provider "azurerm" {
  alias           = "dcd-cnp-dev"
  subscription_id = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
}

terraform {
  backend "azurerm" {}
}
