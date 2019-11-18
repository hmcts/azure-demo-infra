locals {
  payment_api_gateway_certificate_thumbprints = ["B1BF8007527F85085D7C4A3DC406A9A6D124D721", "13D1848E8B050CE55E4D41A35A60FF4A17E686A6", "5E61678A6AC76C2E92F26D1F4AF3D8A327E0D2CE", "68EDF481C5394D65962E9810913455D3EC635FA5", "B1C45E55A1E93AD43A473972CFF490722EEF1E38", "F7C2AB80CFA2721DB41490DC31325977AAA034FE", "B35BCF6C5C9DAEE7D0C756B666FFEDE2CF4659BA", "B9D9E70AC23EAF8EA094F6B59EF77FF77D977CBE"]
  payment_thumbprints_in_quotes               = "${formatlist("&quot;%s&quot;", local.payment_api_gateway_certificate_thumbprints)}"

  payment_thumbprints_in_quotes_str = "${join(",", local.payment_thumbprints_in_quotes)}"
}

module "ccpay-payments-product" {
  source = "../cnp-module-api-mgmt-product"

  api_mgmt_name         = "core-api-mgmt-demodata"
  api_mgmt_rg           = "core-infra-demodata-rg"
  subscription_required = false
  approval_required     = false
  subscriptions_limit   = "0"

  name = "payments"
}

module "ccpay-payments-api" {
  source = "../cnp-module-api-mgmt-api"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  revision     = "1"
  product_id   = "${module.ccpay-payments-product.product_id}"
  name         = "payments-api"
  display_name = "Payments API"
  path         = "payments-api"
  swagger_url  = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/ccpay-payment-app.payments.json"
  service_url  = "${local.payments_api_url}"
}

// TODO, look at why this is generating a new template each time
data "template_file" "payments_policy_template" {
  template = "${file("${path.module}/templates/ccpay-payments-api-policy.xml")}"

  vars = {
    allowed_certificate_thumbprints = "${local.payment_thumbprints_in_quotes_str}"
    s2s_client_id                   = "${local.api_gateway_s2s_client_id}"
    s2s_client_secret               = "${local.api_gateway_s2s_dummy_secret}"
    s2s_base_url                    = "${local.s2s_base_url}"
  }
}

module "ccpay-payments-policy" {
  source = "../cnp-module-api-mgmt-api-policy"

  api_mgmt_name = "core-api-mgmt-demodata"
  api_mgmt_rg   = "core-infra-demodata-rg"

  api_name               = "${module.ccpay-payments-api.name}"
  api_policy_xml_content = "${data.template_file.payments_policy_template.rendered}"
}
