variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "openai_key" {
  description = "Azure OpenAI API Key"
  type        = string
  sensitive   = true
}

variable "azdo_pat" {
  description = "Azure DevOps Personal Access Token"
  type        = string
  sensitive   = true
}

variable "gh_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "container_image" {
  description = "Container image for the agent"
  type        = string
  default     = "ghcr.io/your-org/artifact-retirement-agent:latest"
}