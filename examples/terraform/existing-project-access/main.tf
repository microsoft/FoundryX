terraform {
  required_version = ">= 1.7"
  required_providers {
    foundryx = {
      source  = "smallblackhole/foundryx"
      version = "0.0.5"
    }
  }
}

variable "tenant_id" {
  type        = string
  description = "Microsoft Entra tenant UUID for the signed-in CLI session."
}

variable "project_arm_id" {
  type        = string
  description = "Azure resource ID of the existing Foundry project."
}

variable "allowed_models" {
  type        = set(string)
  description = "Complete set of model deployment names to allow."
}

variable "allowed_tools" {
  type        = set(string)
  description = "Complete set of tool keys to allow."
}

variable "user_object_id" {
  type        = string
  description = "Microsoft Entra object UUID of the user receiving Consumer access."
}

provider "foundryx" {
  tenant_id = var.tenant_id
}

resource "foundryx_project_registration" "project" {
  project_arm_id = var.project_arm_id
}

resource "foundryx_project_policy" "policy" {
  project_id     = foundryx_project_registration.project.project_id
  allowed_models = var.allowed_models
  allowed_tools  = var.allowed_tools
}

resource "foundryx_project_member" "consumer" {
  project_id     = foundryx_project_registration.project.project_id
  principal_type = "user"
  principal_id   = var.user_object_id
  role           = "consumer"

  depends_on = [foundryx_project_policy.policy]
}
