terraform {
  backend "gcs" {
    bucket = "tf-state-daring-emitter-457812-v7"
    prefix = "quote-api"
  }
}
