# SOS-PKI
Simple OpenSSL PKI for development &amp; testing environments

## Reason
When developing and testing secure software certificates need to be used to secure the transport layer of the application. Most products are build for production environments like: 
- [OpenXPKI](http://www.openxpki.org)
- [CloudFlare - CFSSL](https://github.com/cloudflare/cfssl)
- [Microsoft - AD CS](https://technet.microsoft.com/en-us/windowsserver/dd448615.aspx)
- [Let's Encrypt - Boulder](https://github.com/letsencrypt/boulder)
- [PrimeKey - EJBCA](https://www.ejbca.org)

Purpose of this tool is to create a simple to use PKI for development and testing purposes. It is based on OpenSSL so that the functionality can be extended, is standard conform and can be reproduced.

## Technology &amp; Features
- Developed with Ruby and Docker
- Should be packaged to make it also runable on Windows
- Usage of REST webservices
- Method to generate certificates over webservice (test with curl)
- WebUI to generate certificates graphically
- As many output formats as possible (pem, p7, p12, der, jks, etc.)

## Reference
[OpenSSL PKI Tutorial](https://pki-tutorial.readthedocs.io/en/latest/)

## Development
First run the `build_dev_base_docker.sh` script which builds the basic docker image which is needed to develop this application.

Initially and every time you change the Gemfile you need to run the `bundle_install_local.sh` script.

To clean all created directories and delete all created files run `clean_all.sh`

The 'admin.sh' script takes the argument provided and executes the `admin.rb` inside the docker container with these parameter:
- `./admin.sh create-root-ca`
- `./admin.sh create-cert --name "NameOfCert" --san "domain.com,second.domain.com" --password "password"`

Following scripts should be self explanatory:
- `create_root_ca.sh`
- `run_server.sh`

