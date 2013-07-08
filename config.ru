require "./app"

if settings.environment == :development
  require 'rack-livereload'
  require 'pry'
  use Rack::LiveReload
end

run Sinatra::Application
