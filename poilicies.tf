##############################################################
# Policy Definition For Resources Deployment Locations
##############################################################
resource "azurerm_policy_definition" "location" {
  name         = "only-deploy-in-westeurope-northeurope"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed resource types"

  policy_rule = <<POLICY_RULE
 {
    "if": {
      "not": {
        "field": "location",
        "in": ["westeurope", "northeurope"]
      }
    },
    "then": {
      "effect": "Deny"
    }
  }
POLICY_RULE
}

##############################################################
# Policy Assignement On Subscription
##############################################################
resource "azurerm_subscription_policy_assignment" "spa" {
  name                 = "locations"
  policy_definition_id = azurerm_policy_definition.location.id
  subscription_id      = data.azurerm_subscription.primary.id
}

##############################################################
# Conditional Acces Polocy -> Force MFA
##############################################################
resource "azuread_conditional_access_policy" "mfa" {
  display_name = "Force MFA"
  state        = "disabled"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
      excluded_applications = []
    }

    locations {
      included_locations = ["All"]
      excluded_locations = ["AllTrusted"]
    }

    platforms {
      included_platforms = ["all"]
    }

    users {
      included_groups = [azuread_group.it.id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }

  session_controls {
    application_enforced_restrictions_enabled = true
    sign_in_frequency                         = 10
    sign_in_frequency_period                  = "hours"
    cloud_app_security_policy                 = "monitorOnly"
  }
}
