module "timestream_db" {
  source                                  = "./modules/timestream"
  project_name                            = local.name
  memory_store_retention_period_in_hours  = 24
  magnetic_store_retention_period_in_days = 7
  tags                                    = local.standard_tags
}