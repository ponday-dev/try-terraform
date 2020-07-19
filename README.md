# try-terraform

Terraformをお試ししたリポジトリ

## Usage

### deploy

1. clone this repo.

```sh
git clone https://github.com/ponday-dev/try-terraform
```

2. create `terraform.tfvars`

```conf
access_key = "<Your IAM access key>"
secret_key = "<Your IAM secret key>"
bucket_name = "<Bucket name>"
```

3. deploy

```sh
terraform apply
```

### destroy

1. run destroy

```sh
terraform destroy
```

At this time, an error will occur when try to remove the origin access identity.

2. remove cloudfront manually

Open your web browser and access AWS management console. Delete the CloudFront distribution manually.

3. run destroy again

When deleting the CloudFront distribution is over, please run `terraform destroy` again.

```sh
terraform destroy
```
