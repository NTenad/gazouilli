require 'active_record'
require 'sinatra'
require 'twitter'
require 'pry'

Twitter.configure do |config|
  config.consumer_key = "fowYkbskZpEwmLh0sbtF1w"
  config.consumer_secret = "Zj1i9RkRFik1mrXNGnzsYdCSlQ6wcEuHvNVYpEzvo"
  config.oauth_token = "1374547314-gflGRLXi2Hfq8tYspk5KkRyxHq5c3jI3PIYz1Jp"
  config.oauth_token_secret = "HSHzwNCMDXP192ZEqKpIXzrp9uuZQtaKRMMInsyWk"
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database:  'db/gazouilli.db'
)

class Tweet < ActiveRecord::Base
end

get '/' do
  twitter_tweets = Twitter.user_timeline('simplonco')
  local_tweets = Tweet.all

  @tweets = twitter_tweets + local_tweets

  erb :tweets
end

# create tweet
post '/tweets' do
  Tweet.create(text: params[:text])

  redirect '/'
end
