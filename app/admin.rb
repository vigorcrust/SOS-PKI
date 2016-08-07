require 'fileutils'
require 'getoptlong'

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


def create_rootca_key_and_csr
  system('openssl req -new -config config/root-ca.conf -out ca/root-ca.csr -keyout ca/root-ca/private/root-ca.key')
end

# ---- Commandline Parser ----
opts = GetoptLong.new( 
	[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
	[ '--create-root-ca', GetoptLong::NO_ARGUMENT],
	[ '--create-signing-ca', GetoptLong::NO_ARGUMENT],
	[ '--create-server-cert', GetoptLong::NO_ARGUMENT],
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
      create_rootca_key_and_csr
    when '--create-signing-ca'
      init_structure('signing-ca')
    when '--create-cert'
    when '--clean-all'
      init_structure('clean')
  end
end
