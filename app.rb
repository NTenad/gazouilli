require 'sinatra'
require 'twitter'
require 'pry'

Twitter.configure do |config|
  config.consumer_key = "fowYkbskZpEwmLh0sbtF1w"
  config.consumer_secret = "Zj1i9RkRFik1mrXNGnzsYdCSlQ6wcEuHvNVYpEzvo"
  config.oauth_token = "1374547314-gflGRLXi2Hfq8tYspk5KkRyxHq5c3jI3PIYz1Jp"
  config.oauth_token_secret = "HSHzwNCMDXP192ZEqKpIXzrp9uuZQtaKRMMInsyWk"
end

get '/' do
  @tweets = Twitter.user_timeline('simplonco')

  erb :tweets
end

post '/tweets' do
    binding.pry
    redirect '/'
end
