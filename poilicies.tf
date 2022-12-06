resource "azurerm_policy_definition" "location" {
  name         = "only-deploy-in-westeurope-northeuropê"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed resource types"

  policy_rule = <<POLICY_RULE
 {
    "if": {
      "not": {
        "field": "location",
        "equals": ["westeurope", "northeurope"]
      }
    },
    "then": {
      "effect": "Deny"
    }
  }
POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "spa" {
  name                 = "locations"
  policy_definition_id = azurerm_policy_definition.location.id
  subscription_id      = data.azurerm_subscription.primary.id
}
