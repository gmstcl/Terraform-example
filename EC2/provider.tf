provider "aws" {
}

data "http" "myip" {
  url = "https://myip.wtf/text"
}