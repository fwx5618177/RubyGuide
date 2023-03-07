require 'swagger_ui_engine'

class MyApp < Sinatra::Base
  use SwaggerUiEngine::Engine, at: '/swagger'
end
