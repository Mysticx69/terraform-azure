##############################################################
# AD Group And Users
##############################################################
data "azuread_group" "GlobalAdmin" {
  display_name     = "GlobalAdmin"
  security_enabled = true
}

resource "azuread_user" "admin" {
  user_principal_name = "AdminTF@${data.azuread_domains.default.domains.0.domain_name}"
  display_name        = "Admin Terraform"
  city                = "Lyon"
  company_name        = "CPE Lyon"
  department          = "IT"
  password            = "defaultpasswd@22!"
  usage_location      = "FR"
}

resource "azuread_group_member" "admin_gm" {
  group_object_id  = data.azuread_group.GlobalAdmin.id
  member_object_id = azuread_user.admin.id
}

resource "azuread_user" "administratif" {
  user_principal_name = "RH@${data.azuread_domains.default.domains.0.domain_name}"
  display_name        = "RH Terraform"
  city                = "Lyon"
  company_name        = "CPE Lyon"
  department          = "Administratif"
  password            = "defaultpasswd@22!"
}

resource "azuread_group" "administratif_group" {
  display_name       = "Administratif TF"
  security_enabled   = true
  owners             = [data.azuread_client_config.current.object_id]
  types              = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule = "user.department -eq \"Administratif\""
  }
}

