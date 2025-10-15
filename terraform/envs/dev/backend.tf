terraform {
  backend "gcs" {
    bucket = "erp-konecta-terraform-state"
    prefix = "dev/terraform.tfstate"
  }
}