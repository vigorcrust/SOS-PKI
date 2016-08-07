require 'fileutils'
require 'getoptlong'
require 'highline/import'

def init_structure(typeof_structure)
  case typeof_structure
    when 'clean'
      FileUtils.rm_rf('./ca')
      FileUtils.rm_rf('./crl')
      FileUtils.rm_rf('./certs')
    when 'root-ca'
      FileUtils.mkdir_p './ca/root-ca/private'
      FileUtils.mkdir_p './ca/root-ca/db'
      FileUtils.touch './ca/root-ca/db/root-ca.db'
      FileUtils.touch './ca/root-ca/db/root-ca.db.attr'
      File.open('./ca/root-ca/db/root-ca.crt.srl', 'w') {|f| f.write("01")}
      File.open('./ca/root-ca/db/root-ca.crl.srl', 'w') {|f| f.write("01")}
    when 'signing-ca'
      FileUtils.mkdir_p './ca/signing-ca/private'
      FileUtils.mkdir_p './ca/signing-ca/db'
      FileUtils.touch './ca/signing-ca/db/signing-ca.db'
      FileUtils.touch './ca/signing-ca/db/signing-ca.db.attr'
      File.open('./ca/signing-ca/db/signing-ca.crt.srl', 'w') {|f| f.write("01")}
      File.open('./ca/signing-ca/db/signing-ca.crl.srl', 'w') {|f| f.write("01")}
  end

  FileUtils.mkdir_p 'crl'
  FileUtils.mkdir_p 'certs'
end


def create_rootca_key_and_csr(passout)
  system("openssl req -new -config config/root-ca.conf -out ca/root-ca.csr -keyout ca/root-ca/private/root-ca.key -passout pass:#{passout}")
end
def create_rootca_cert(passin)
  system("openssl ca -selfsign -batch -config config/root-ca.conf -in ca/root-ca.csr -out ca/root-ca.crt -extensions root_ca_ext -passin pass:#{passin}")
end
def create_signing_key_and_csr(passout)
  system("openssl req -new -config config/signing-ca.conf -out ca/signing-ca.csr -keyout ca/signing-ca/private/signing-ca.key -passout pass:#{passout}")
end
def create_signingca_cert
  system("openssl ca -batch -config config/root-ca.conf -in ca/signing-ca.csr -out ca/signing-ca.crt -extensions signing_ca_ext")
end
def create_server_key_and_csr(san = 'DNS:simple.org', name = 'simple')
  system("SAN=#{san} openssl req -new -config config/server.conf -out certs/#{name}.csr -keyout certs/#{name}.key")
end
def create_server_cert(name = 'simple')
  system("openssl ca -batch -config config/signing-ca.conf -in certs/#{name}.csr -out certs/#{name}.crt -extensions server_ext")
end

# ---- Helpers ----
def input(reason = "")
  pass = ""
  3.times do
    pass_initial = ask("Enter #{reason}password: ")  { |q| q.echo = "*" }
    pass_verify  = ask("Verify #{reason}password: ") { |q| q.echo = "*" }
    if pass_initial == pass_verify && pass_initial.length > 3
      pass = pass_verify
      return pass
    else
      puts "Password not equal or to short. Retry."
    end
  end
  puts "No valid passwords given."
  return
end

# ---- Commandline Parser ----
opts = GetoptLong.new( 
	[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
	[ '--create-root-ca', GetoptLong::NO_ARGUMENT],
	[ '--create-signing-ca', GetoptLong::NO_ARGUMENT],
	[ '--create-cert', GetoptLong::NO_ARGUMENT],
	[ '--clean-all', GetoptLong::NO_ARGUMENT]
)

opts.each do |opt, arg| 
  case opt 
    when '--help' 
      puts <<-EOF
Help::SOS-PKI
--help
  Prints this help.
--create-root-ca
  Creates all files required for the root ca
--create-signing-ca
  Creates all files required for the signing ca
--create-cert
  Creates a certificate what usually the server should do
EOF
    when '--create-root-ca'
      init_structure('root-ca')
      root_ca_private_pass = input('Root-CA ')
      create_rootca_key_and_csr(root_ca_private_pass)
      create_rootca_cert(root_ca_private_pass)
    when '--create-signing-ca'
      init_structure('signing-ca')
      signing_ca_private_pass = input('Signing-CA ')
      create_signing_key_and_csr(signing_ca_private_pass)
      create_signingca_cert
    when '--create-cert'
      create_server_key_and_csr
      create_server_cert
    when '--clean-all'
      init_structure('clean')
  end
end
