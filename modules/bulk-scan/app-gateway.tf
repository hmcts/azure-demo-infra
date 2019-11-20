data "azurerm_key_vault" "infra_vault" {
  provider = "azurerm.legacy"

  name                = var.external_cert_vault
  resource_group_name = var.external_cert_resource_group_name
}

data "azurerm_key_vault_secret" "cert" {
  provider = "azurerm.legacy"

  name         = var.external_cert_name
  key_vault_id = data.azurerm_key_vault.infra_vault.id
}

data "azurerm_subnet" "appgw" {
  name                 = "appgw"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
}

module "appGw" {
  source                            = "github.com/hmcts/cnp-module-waf?ref=master"
  env                               = var.env
  subscription                      = var.subscription
  location                          = var.location
  wafName                           = var.product
  resourcegroupname                 = var.resource_group_name
  common_tags                       = var.tags
  log_analytics_resource_group_name = var.log_analytics_resource_group_name
  log_analytics_resource_suffix     = "-law"

  # vNet connections
  gatewayIpConfigurations = [
    {
      name     = "internalNetwork"
      subnetId = data.azurerm_subnet.appgw.id
    },
  ]

  sslCertificates = [
    {
      name     = var.external_cert_name
      data     = data.azurerm_key_vault_secret.cert.value
      password = ""
    },
  ]

  # Http Listeners
  httpListeners = [
    {
      name                    = "https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = var.external_cert_name
      hostName                = var.external_hostname
    },
  ]

  # Backend address Pools
  backendAddressPools = [
    {
      name = "${var.product}-${var.env}"

      backendAddresses = module.palo_alto.untrusted_ips_ip_address
    },
  ]

  backendHttpSettingsCollection = [
    {
      name                           = "backend"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = var.external_hostname
    },
  ]

  # Request routing rules
  requestRoutingRules = [
    {
      name                = "https"
      RuleType            = "Basic"
      httpListener        = "https-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend"
    },
  ]

  probes = [
    {
      name                                = "http-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend"
      host                                = var.external_hostname
      healthyStatusCodes                  = "200-404" // MS returns 400 on /, allowing more codes in case they change it
    },
  ]
}
