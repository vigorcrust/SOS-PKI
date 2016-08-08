
require 'sinatra'
require_relative 'lib.rb'

set :bind, '0.0.0.0'
set :server, 'thin'

get '/' do
  "Hello PKI"
end
