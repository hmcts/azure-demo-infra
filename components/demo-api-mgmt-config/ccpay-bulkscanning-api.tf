locals {
  ccpaybulkscanning_api_gateway_certificate_thumbprints = ["F4A976E4967F8F4F621C87C67B9E258563F80F0E", "B35BCF6C5C9DAEE7D0C756B666FFEDE2CF4659BA", "B1BF8007527F85085D7C4A3DC406A9A6D124D721"]
  ccpaybulkscanning_thumbprints_in_quotes               = "${formatlist("&quot;%s&quot;", local.ccpaybulkscanning_api_gateway_certificate_thumbprints)}"

  ccpaybulkscanning_thumbprints_in_quotes_str = "${join(",", local.ccpaybulkscanning_thumbprints_in_quotes)}"
}

module "ccpay-bulkscanning-product" {
  source = "github.com/hmcts/cnp-module-api-mgmt-product?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  name = "bulk-scanning-payment"
}

module "ccpay-bulkscanning-api" {
  source = "github.com/hmcts/cnp-module-api-mgmt-api?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  revision     = "1"
  product_id   = "${module.ccpay-bulkscanning-product.product_id}"
  name         = "bulk-scanning-payment-api"
  display_name = "bulk-scanning payments API"
  path         = "bulk-scanning-payment"
  swagger_url  = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.bulk-scanning.json"
  service_url  = "https://bulk-scanning-payment-api.demo.platform.hmcts.net"
}

// TODO, look at why this is generating a new template each time
data "template_file" "bulkscanning_policy_template" {
  template = "${file("${path.module}/templates/ccpay-bulkscanning-api-policy.xml")}"

  vars = {
    allowed_certificate_thumbprints = "${local.ccpaybulkscanning_thumbprints_in_quotes_str}"
    s2s_client_id                   = "${local.api_gateway_s2s_client_id}"
    s2s_client_secret               = "${local.api_gateway_s2s_dummy_secret}"
    s2s_base_url                    = "${local.s2s_base_url}"
  }
}

module "ccpay-bulkscanning-policy" {
  source = "github.com/hmcts/cnp-module-api-mgmt-api-policy?ref=master"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  api_name               = "${module.ccpay-bulkscanning-api.name}"
  api_policy_xml_content = "${data.template_file.bulkscanning_policy_template.rendered}"
}
