require 'grape'
require 'grape-swagger'

class MyAPI < Grape::API
  format :json

  desc 'Return a hello world message'
  get '/hello' do
    { message: 'Hello, world!' }
  end

  add_swagger_documentation
end
