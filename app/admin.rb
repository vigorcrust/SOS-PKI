require 'optparse'
require_relative 'lib.rb'


# ---- Commandline Parser ----
options = {}

global = OptionParser.new do |opts|
  opts.banner = "Usage: admin.rb command [[option] | subcommand [option]]"
end
subcommands = { 
  'create-cert' => OptionParser.new do |opts|
    opts.banner = "Usage: create-cert [option]"
    opts.on("") do |v|
      options[:command] = 'create-cert'
    end
    opts.on("-n certname", "--name certname", "name of cert") do |v|
      options[:name] = v
    end
    opts.on("-s sanstring", "--san sanstring", "san of cert") do |v|
      options[:san] = v
    end
    opts.on("-p password", "--password password", "password of signing ca") do |v|
      options[:password] = v
    end
  end,
  'create-root-ca' => OptionParser.new do |opts|
    opts.banner = "Usage: create-root-ca"
    opts.on("") do |v|
      options[:command] = 'create-root-ca'
    end
  end,
  'create-signing-ca' => OptionParser.new do |opts|
    opts.banner = "Usage: create-signing-ca"
    opts.on("") do |v|
      options[:command] = 'create-signing-ca'
    end
  end,
  'clean-all' => OptionParser.new do |opts|
    opts.banner = "Usage: clean all"
    opts.on("") do |v|
      options[:command] = 'clean-all'
    end
  end
}

global.order!
subcommands[ARGV.shift].order!

# ---- Command execution ----

case options[:command]
  when 'create-cert'
    create_server_key_and_csr(options[:san], options[:name])
    create_server_cert(options[:name], options[:password])
  when 'create-root-ca'
    init_structure('root-ca')
    root_ca_private_pass = input('Root-CA ')
    create_rootca_key_and_csr(root_ca_private_pass)
    create_rootca_cert(root_ca_private_pass)
  when 'create-signing-ca'
    init_structure('signing-ca')
    signing_ca_private_pass = input('Signing-CA ')
    create_signing_key_and_csr(signing_ca_private_pass)
    create_signingca_cert
  when 'clean-all'
    init_structure('clean')
end
