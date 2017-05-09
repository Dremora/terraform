variable "do_token" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "digitalocean" {
    token = "${var.do_token}"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "eu-west-1"
}

resource "digitalocean_ssh_key" "mykey" {
    name = "kirill.korolyov@gmail.com"
    public_key = "${file("/Users/dremora/.ssh/id_rsa.pub")}"
}

resource "digitalocean_droplet" "zazu" {
    size = "512mb"
    region = "lon1"
    image = ""
    name = "zazu"
    ssh_keys = ["${digitalocean_ssh_key.mykey.id}"]
}

resource "aws_route53_zone" "dremora_com" {
    name = "dremora.com."
}

resource "aws_route53_record" "dremora_com" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "dremora.com"
    type = "A"
    ttl = "3600"
    records = ["192.30.252.153", "192.30.252.154"]
}

resource "aws_route53_record" "soa" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "dremora.com"
    type = "SOA"
    ttl = "900"
    records = ["ns-332.awsdns-41.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
}

resource "aws_route53_record" "ns" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "dremora.com"
    type = "NS"
    ttl = "172800"
    records = [
      "ns-332.awsdns-41.com",
      "ns-1031.awsdns-00.org",
      "ns-953.awsdns-55.net",
      "ns-1708.awsdns-21.co.uk"
    ]
}

resource "aws_route53_record" "www" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "www"
    type = "CNAME"
    ttl = "3600"
    records = ["dremora.com"]
}

resource "aws_route53_record" "patches" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "patches"
    type = "CNAME"
    ttl = "3600"
    records = ["dremora.com"]
}

resource "aws_route53_record" "my_music" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "my-music"
    type = "CNAME"
    ttl = "3600"
    records = ["zazu.dremora.com"]
}

resource "aws_route53_record" "my_music_api" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "my-music-api"
    type = "CNAME"
    ttl = "300"
    records = ["zazu.dremora.com"]
}

resource "aws_route53_record" "color_lines" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "color-lines"
    type = "CNAME"
    ttl = "300"
    records = ["${aws_s3_bucket.color-lines.website_endpoint}"]
}

resource "aws_route53_record" "words" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "words"
    type = "CNAME"
    ttl = "300"
    records = ["my-words-1.s3-website-us-east-1.amazonaws.com"]
}

resource "aws_route53_record" "zazu" {
    zone_id = "${aws_route53_zone.dremora_com.zone_id}"
    name = "zazu"
    type = "A"
    ttl = "3600"
    records = ["${digitalocean_droplet.zazu.ipv4_address}"]
}

resource "aws_s3_bucket" "color-lines" {
    bucket = "color-lines.dremora.com"
    website {
        index_document = "index.html"
    }
}

resource "aws_s3_bucket_policy" "color-lines" {
  bucket = "${aws_s3_bucket.color-lines.id}"
  policy = "${file("color-lines-policy.json")}"
}
