####################################################################################
#
# WAF WebACL
#

resource "aws_wafv2_web_acl" "waf_acl"{
  count = var.create ? 1 : 0

  name        = var.web_acl_name
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_webacl_action ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.default_webacl_action ? [] : [1]
      content {}
    }
  }

  dynamic "visibility_config" {
    for_each = var.visibility_config
    content {
      cloudwatch_metrics_enabled  = lookup(visibility_config.value, "cloudwatch_metrics_enabled", null)
      metric_name                 = lookup(visibility_config.value, "metric_name", var.web_acl_name)
      sampled_requests_enabled    = lookup(visibility_config.value, "sampled_requests_enabled", null)
    }
  }

  dynamic "rule" {
    for_each = var.managed_rule_group
    content {

      priority  = lookup(rule.value, "priority", null)
      name      = lookup(rule.value, "name", null)

      override_action {
        dynamic "none" {
          for_each = length(lookup(rule.value, "override_action", {})) == 0 || lookup(rule.value, "override_action", {}) == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = lookup(rule.value, "override_action", {}) == "count" ? [1] : []
          content {}
        }
      }

      dynamic "statement" {
        for_each = length(keys(lookup(rule.value, "statement", {}))) == 0 ? [] : [lookup(rule.value, "statement", {})]
        content {

          dynamic "managed_rule_group_statement" {
            for_each = length(keys(lookup(statement.value, "managed_rule_group_statement", {}))) == 0 ? [] : [lookup(statement.value, "managed_rule_group_statement", {})]
            content {
              name        = managed_rule_group_statement.value.name
              vendor_name = lookup(managed_rule_group_statement.value, "vendor_name", null)

              dynamic "excluded_rule" {
                for_each = lookup(managed_rule_group_statement.value, "excluded_rule", var.excluded_rule)
                content {
                  name = lookup(excluded_rule.value, "name", null)
                }
              }
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = length(keys(lookup(rule.value, "visibility_config", {}))) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled  = lookup(visibility_config.value, "cloudwatch_metrics_enabled", null)
          metric_name                 = lookup(visibility_config.value, "metric_name", var.web_acl_name)
          sampled_requests_enabled    = lookup(visibility_config.value, "sampled_requests_enabled", null)
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rate_based 
    content {

      priority  = lookup(rule.value, "priority", null)
      name      = lookup(rule.value, "name", null)

      action {
        dynamic "allow" {
          for_each = length(lookup(rule.value, "action", {})) == 0 || lookup(rule.value, "action", {}) == "allow" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = lookup(rule.value, "action", {}) == "count" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = lookup(rule.value, "action", {}) == "block" ? [1] : []
          content {}
        }
      }

      dynamic "statement" {
        for_each = length(keys(lookup(rule.value, "statement", {}))) == 0 ? [] : [lookup(rule.value, "statement", {})]
        content {

          dynamic "rate_based_statement" {
            for_each = length(keys(lookup(statement.value, "rate_based_statement", {}))) == 0 ? [] : [lookup(statement.value, "rate_based_statement", {})]
            content {
              limit               = lookup(rate_based_statement.value, "limit", null)
              aggregate_key_type  = lookup(rate_based_statement.value, "aggregate_key_type", null)

              dynamic "scope_down_statement" {
                for_each = length(keys(lookup(statement.value, "scope_down_statement", {}))) == 0 ? [] : [lookup(statement.value, "scope_down_statement", {})]
                content {

                  dynamic "geo_match_statement" {
                    for_each = length(keys(lookup(scope_down_statement.value, "geo_match_statement", {}))) == 0 ? [] : [lookup(scope_down_statement.value, "geo_match_statement", {})]
                    content {
                      country_codes = lookup(geo_match_statement.value, "country_codes", null)
                    }
                  }
                }
              }
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = length(keys(lookup(rule.value, "visibility_config", {}))) == 0 ? [] : [lookup(rule.value, "visibility_config", {})]
        content {
          cloudwatch_metrics_enabled  = lookup(visibility_config.value, "cloudwatch_metrics_enabled", null)
          metric_name                 = lookup(visibility_config.value, "metric_name", var.web_acl_name)
          sampled_requests_enabled    = lookup(visibility_config.value, "sampled_requests_enabled", null)
        }
      }
    }
  }

  tags = var.default_tags
}

#resource "aws_wafv2_rule_group" "main" {
#    count = var.create ? 1 : 0
#
#}

resource "aws_wafv2_web_acl_association" "main" {
  count = var.create ? length(var.resource_association) : 0

  resource_arn = lookup(var.resource_association[count.index], "resource_association_arn", null)
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.0.arn
}