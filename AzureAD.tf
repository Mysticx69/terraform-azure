##############################################################
# Active Directory User, Groups And Roles
##############################################################

##############################################################
# IT Group
##############################################################
resource "azuread_group" "it" {
  display_name            = "IT"
  description             = "Group for admins users. All rights on Azure AD and Owner role on subscription"
  owners                  = [data.azuread_client_config.current.object_id]
  prevent_duplicate_names = true
  security_enabled        = true
  assignable_to_role      = true
  members = [azuread_user.jcive.object_id,
    azuread_user.scroche.object_id,
  azuread_user.hbonisseur.object_id]
}

##############################################################
# Directory/Administrator Role For IT Group
##############################################################
resource "azuread_directory_role" "admin" {
  display_name = "Global administrator"
}

##############################################################
# Assign Global Administrator Role to IT group
##############################################################
resource "azuread_directory_role_assignment" "example" {
  role_id             = azuread_directory_role.admin.template_id
  principal_object_id = azuread_group.it.object_id
}

##############################################################
# Assign Owner Role On Subscription For IT Group
##############################################################
resource "azurerm_role_assignment" "owners" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.it.object_id
}

##############################################################
# Administratif Group
##############################################################
resource "azuread_group" "administratif" {
  display_name            = "Administratif"
  description             = "Group for adminitratif users. No rights on Azure AD and Contributor role on subscription"
  security_enabled        = true
  prevent_duplicate_names = true
  owners                  = [data.azuread_client_config.current.object_id]
  types                   = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "user.department -eq \"Administratif\""
  }
}

##############################################################
# Assign Contributor Role On Subscription For Administratif Group
##############################################################
resource "azurerm_role_assignment" "contributors" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.administratif.object_id
}

##############################################################
# IT Users
##############################################################
resource "azuread_user" "jcive" {
  user_principal_name   = "jcive@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = "Jean Cive"
  city                  = "Lyon"
  company_name          = "CPE Lyon"
  department            = "IT"
  password              = "defaultpasswd@22!"
  force_password_change = true
  usage_location        = "FR"
}

resource "azuread_user" "scroche" {
  user_principal_name   = "scroche@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = "Sarah Croche"
  city                  = "Lyon"
  company_name          = "CPE Lyon"
  department            = "IT"
  password              = "defaultpasswd@22!"
  force_password_change = true
  usage_location        = "FR"
}

resource "azuread_user" "hbonisseur" {
  user_principal_name   = "hbonisseur@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = "Hubert Bonisseur-Delabath"
  city                  = "Lyon"
  company_name          = "CPE Lyon"
  department            = "IT"
  password              = "defaultpasswd@22!"
  force_password_change = true
  usage_location        = "FR"
}


##############################################################
# Administratif Users
##############################################################
resource "azuread_user" "bafritt" {
  user_principal_name   = "bafritt@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = "Barack Afritt"
  city                  = "Lyon"
  company_name          = "CPE Lyon"
  department            = "Administratif"
  password              = "defaultpasswd@22!"
  force_password_change = true
  usage_location        = "FR"
}

resource "azuread_user" "azauffray" {
  user_principal_name   = "azauffray@${data.azuread_domains.default.domains[0].domain_name}"
  display_name          = "Annie-Zette Auffray"
  city                  = "Lyon"
  company_name          = "CPE Lyon"
  department            = "Administratif"
  password              = "defaultpasswd@22!"
  force_password_change = true
  usage_location        = "FR"
}
