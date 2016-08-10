require 'fileutils'
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
  system("openssl req -new -config config/root-ca.conf -out ca/root-ca.csr -keyout ca/root-ca/private/root-ca.key -passout pass:\"#{passout}\"")
end
def create_rootca_cert(passin)
  system("openssl ca -selfsign -batch -config config/root-ca.conf -in ca/root-ca.csr -out ca/root-ca.crt -extensions root_ca_ext -passin pass:\"#{passin}\"")
end
def create_signing_key_and_csr(passout)
  system("openssl req -new -config config/signing-ca.conf -out ca/signing-ca.csr -keyout ca/signing-ca/private/signing-ca.key -passout pass:\"#{passout}\"")
end
def create_signingca_cert
  system("openssl ca -batch -config config/root-ca.conf -in ca/signing-ca.csr -out ca/signing-ca.crt -extensions signing_ca_ext")
end
def create_server_key_and_csr(san = 'simple.org', name = 'simple', password = '')
  san_domains = san.split(',')
  san_string = ""
  for i in 1..san_domains.length
    san_string += "SAN#{i}=#{san_domains[i-1]} "
  end
  for i in san_domains.length+1..5
    san_string += "SAN#{i}=\"\" "
  end
  system("#{san_string} COMMON_NAME=#{name} openssl req -new -config config/server.conf -out certs/#{name}.csr -keyout certs/#{name}.key")
end
def create_server_cert(name = 'simple', password = '')
  system("openssl ca -batch -config config/signing-ca.conf -in certs/#{name}.csr -out certs/#{name}.crt -extensions server_ext -passin pass:\"#{password}\"")
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
