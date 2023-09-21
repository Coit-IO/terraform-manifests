variable "instanceCount" {
  type    = number
  default = 1
}

variable "ami" {
  type    = string
  default = "ami-0726555fb5b46ab38"
}

variable "keypairs" {
  type    = list(string)
  default = ["basilmac", "may29", "jun1"]
}

variable "commonLabels" {
  type    = tuple([string, string, string])
  default = ["myorganization1", "mumbai", "india"]
}

variable "commonTags" {
  type = map(string)
  default = {
    "country"      = "India"
    "location"     = "Mumbai"
    "organization" = "myorganization1"
  }
}
