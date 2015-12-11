require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :outboard_file, 'https://docs.google.com/document/d/17lRuhymf-B7Pk8HGrszRW-_dwYvR6cSrovxAxxgAbA4/export?format=txt'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
