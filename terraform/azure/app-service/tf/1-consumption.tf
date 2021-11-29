
resource "azurerm_monitor_action_group" "action_group" {
  name                = "action-group-${var.environment}-${var.location}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  short_name          = "example"
}

resource "azurerm_consumption_budget_resource_group" "consumption_budget_resource_group" {
  name              = "consumtion-budget-${var.environment}-${var.location}"
  resource_group_id = data.azurerm_resource_group.resource_group.id

  amount     = 5
  time_grain = "Monthly"

  time_period {
    start_date = "2021-11-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceId"
      values = [
        azurerm_monitor_action_group.action_group.id,
      ]
    }

    tag {
      name = "foo"
      values = [
        "bar",
        "baz",
      ]
    }
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "EqualTo"
    threshold_type = "Forecasted"

    contact_emails = [
      "0xffea@gmail.com",
    ]

    contact_roles = [
      "Owner",
    ]
  }

  notification {
    enabled   = true
    threshold = 100.0
    operator  = "GreaterThan"

    contact_emails = [
      "0xffea@gmail.com",
    ]
  }
}
