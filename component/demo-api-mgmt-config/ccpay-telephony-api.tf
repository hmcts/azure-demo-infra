locals {
  telephony_api_gateway_certificate_thumbprints = ["B1BF8007527F85085D7C4A3DC406A9A6D124D721", "68EDF481C5394D65962E9810913455D3EC635FA5", "13D1848E8B050CE55E4D41A35A60FF4A17E686A6", "C46826BF1E82DF37664F7A3678E6498D056DA4A9", "B660C97A7CC2734ABD41FBF9F6ADAA61B0C399D4", "B35BCF6C5C9DAEE7D0C756B666FFEDE2CF4659BA"]
  telephony_thumbprints_in_quotes               = "${formatlist("&quot;%s&quot;", local.telephony_api_gateway_certificate_thumbprints)}"
  telephony_thumbprints_in_quotes_str           = "${join(",", local.telephony_thumbprints_in_quotes)}"
}

module "ccpay-telephony-product" {
  source = "../cnp-module-api-mgmt-product"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  name = "telephony"
}

module "ccpay-telephony-api" {
  source = "../cnp-module-api-mgmt-api"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  revision     = "1"
  product_id   = "${module.ccpay-telephony-product.product_id}"
  name         = "telephony-api"
  display_name = "Telephony API"
  path         = "telephony-api"
  swagger_url  = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.telephony.json"
  service_url  = "${local.payments_api_url}"
}

// TODO, look at why this is generating a new template each time
data "template_file" "telephony_policy_template" {
  template = "${file("${path.module}/templates/ccpay-telephony-api-policy.xml")}"

  vars = {
    allowed_certificate_thumbprints = "${local.telephony_thumbprints_in_quotes_str}"
    s2s_client_id                   = "${local.api_gateway_s2s_client_id}"
    s2s_client_secret               = "${local.api_gateway_s2s_dummy_secret}"
    s2s_base_url                    = "${local.s2s_base_url}"
  }
}

module "ccpay-telephony-policy" {
  source = "../cnp-module-api-mgmt-api-policy"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  api_name               = "${module.ccpay-telephony-api.name}"
  api_policy_xml_content = "${data.template_file.telephony_policy_template.rendered}"
}
