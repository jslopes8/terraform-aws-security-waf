# Terraform Module AWS WAF

Terraform module irá provisionar os seguintes recursos:

* [WAF WebACL](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_web_acl)

## Usage
```hcl
module "waf_webacl" {
  source = "git@github.com:jslopes8/terraform-aws-security-waf.git?ref=v0.1"

  web_acl_name  = "tf-webacl-prod"
  description   = "Example of a managed rule."
  scope         = "REGIONAL"

  default_webacl_action = "true"

  visibility_config = [{
    cloudwatch_metrics_enabled  = "true"
    sampled_requests_enabled    = "true"
  }]

  managed_rule_group = [
    {
      name      = "tf-webacl-prod-1"
      priority  = "1"

      override_action   = "count"

      statement         = {
        managed_rule_group_statement = {
          name          = "AWSManagedRulesCommonRuleSet"
          vendor_name   = "AWS"

          excluded_rule = [{
            name = "SizeRestrictions_QUERYSTRING"},
          {
            name = "NoUserAgent_HEADER"
          }]
        }
      }

      visibility_config = {
        cloudwatch_metrics_enabled  = "true"
        sampled_requests_enabled    = "true"
      }
    },
    {
      name      = "tf-webacl-prod-0"
      priority  = "0"

      override_action   = "count"

      statement = {
        managed_rule_group_statement = {
          name          = "AWSManagedRulesPHPRuleSet"
          vendor_name   = "AWS"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled  = "true"
        sampled_requests_enabled    = "true"
      }
    }
  ]

  default_tags = {
    Env = "Sandbox"
    Team = "CloudTeam"
  }
}
```

## Requirements
| Name | Version |
| ---- | ------- |
| aws | ~> 3.18 |
| terraform | ~> 0.13 |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Variables Inputs
| Name | Description | Required | Type | Default |
| ---- | ----------- | -------- | ---- | ------- |
| web_acl_name | O name do seu WAF WebACL. | `yes` | `string` | `` |
| description | Uma descrição para o seu WebACL. | `no` | `string` | `null` |
| default_webacl_action | A ação a ser executada se nenhum dos rulescontidos no WebACL corresponder. Especifica que o AWS WAF deve permitir solicitações por padrão, valor `true`. Especifica que o AWS WAF deve bloquear solicitações por padrão, valor `false`. | `yes` | `bool` | `true` |
| visibility_config | Define e ativa as métricas para o CloudWatch e a coleta de amostra de solicitação da web. | `yes` | `list` | `[]` |
| managed_rule_group | Uma declaração de regra usada para executar as regras que são definidas em um grupo de regras gerenciado pela AWS. | `yes` | `list` | `[]` |
| default_tags | Block de chave-valor que fornece o taggeamento para todos os recursos criados em seu WAF WebACL. | `no` | `map` |`{}` |
| rate_based | Uma regra baseada em taxa rastreia a taxa de solicitações para cada origem IP addresse aciona a ação da regra quando a taxa excede um limite que você especifica no número de solicitações em qualquer 5-minuteintervalo de tempo. | `no` | `list` | `[]` |

## Variable Outputs
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
| Name | Description |
| ---- | ----------- |
| id | O ID do WAF WebACL. |
| arn | O ARN do WAF WebACL. |
| capacity | A unidade de capacidade (WCUs) que atualmente o WebACL esta usando. |