locals {
  bulkscanning_api_gateway_certificate_thumbprints = ["2A1EE53E044632145C89FE428128080353127DF6", "5865F09316FEDD32D870F7F07F06D2B5E0D4782D"]
  bulkscanning_thumbprints_in_quotes               = formatlist("&quot;%s&quot;", local.bulkscanning_api_gateway_certificate_thumbprints)

  bulkscanning_thumbprints_in_quotes_str = join(",", local.bulkscanning_thumbprints_in_quotes)
}

module "bulk_scan_product" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  name = "bulk-scan"
}

module "bulk_scan_api" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  revision     = "1"
  product_id   = module.bulk_scan_product.product_id
  name         = "bulk-scan-api"
  display_name = "bulk-scan-api"
  path         = "bulk-scan"
  swagger_url  = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/bulk-scan-processor.json"
  service_url  = "https://bsp-standalone-processor.demo.platform.hmcts.net"
}

data "template_file" "bulk_scan_api_policy_template" {
  template = file("${path.module}/templates/bulk-scan-api-policy.xml")

  vars = {
    allowed_certificate_thumbprints = local.bulkscanning_thumbprints_in_quotes_str
  }
}

module "bulk_scan_api_policy" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  api_name               = module.bulk_scan_api.name
  api_policy_xml_content = data.template_file.bulk_scan_api_policy_template.rendered
}
