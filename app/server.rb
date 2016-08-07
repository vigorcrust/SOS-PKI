
require 'sinatra'

set :bind, '0.0.0.0'
set :server, 'thin'

get '/' do
  "Hello PKI"
end
