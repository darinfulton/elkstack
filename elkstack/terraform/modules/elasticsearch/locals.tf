locals {
  tags_global = {
    AWSBackupPlan   = "None",
    Budget          = "NResearch and Dev AI ML",
    CriticalityTier = "UNKNOWN",
    Department      = "Systems/DEVOPS/sre",
    EnvironmentType = "Dev-QA",
    TFWorkspace     = "sre-testing",
    VeeamBackup     = "None",
  }

  tags_template = merge(
    local.tags_global,
    {
      Name             = "UNKNOWN",
      TechnicalPOC     = "UNKNOWN",
      ConfidentialData = "No",
      ProjectOrPurpose = "Sandbox Testing",
      ManagedTenableOS = "windows",
      "Patch Group"    = "None",
    }
  )

  tags_elasticsearch = merge(
    local.tags_global,
    {
      Name             = "Elasticsearch Sandbox",
      TechnicalPOC     = "DevOPS/SRE",
      ConfidentialData = "No",
      ProjectOrPurpose = "Sandbox Testing",
      ManagedTenableOS = "windows",
      "Patch Group"    = "None",
    }
  )
}