# Bundler
require "rubygems"
require "bundler/setup"

# Sinatra
require "sinatra"

# The app
class FishTally < Sinatra::Base
  configure do
    set :public_folder, Proc.new { File.join(root, "static") }
  end

  get '/' do
    erb :about
  end
  
  get '/about' do
    erb :about
  end
  
  get '/contact' do
    erb :contact
  end

end