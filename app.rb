# encoding: utf-8

require 'pry'
require 'active_support'
require 'active_record'
require 'sinatra'
require 'sinatra/flash'
require 'twitter'

#############################################################################
# Setup
#############################################################################

enable :sessions

Twitter.configure do |config|
  config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token        = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database:  'db/gazouilli.db'
)

class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :tweets
end

class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User'
end

class Tweet < ActiveRecord::Base
  belongs_to :user
end

class Twitter::User; alias :screen_name :username; end

helpers do
  def current_user
    username = session[:username]
    User.find_by_username username
  end

  def parse_tweet(tweet)
    tweet.gsub(/@(\w+)/,'<a href="/users/\1">@\1</a>')
  end
end

get '/' do
  twitter_tweets = Twitter.user_timeline('simplonco')
  local_tweets = Tweet.all

  @tweets = twitter_tweets + local_tweets
  @tweets.sort_by! { |tweet| tweet.created_at }.reverse!

  erb :tweets
end

# sign in
get '/sign_in' do
  if session[:user_id].nil?
    erb :sign_in
  else
    flash[:error] = "Vous êtes déjà connecté !"
    redirect back
  end
end

# create session
post '/authenticate' do
  username = params[:username]
  password = params[:password]

  user = User.find_by_username(username)

  if user.password == password
    session[:username] = user.username
    flash[:notice] = "Bienvenue #{user.username} !"
    redirect '/'
  else
    flash[:error] = "Authentification echouée"
    redirect '/sign_in'
  end
end

# logout
get '/logout' do
  session.clear
  flash[:notice] = "Déconnecté"
  redirect '/'
end

# user timeline
get '/users/:username' do
  username = params[:username]
  user = User.find_by_username(username)
  @tweets = user.tweets

  erb :tweets
end

# create tweet
post '/tweets' do
  if current_user
    tweet = Tweet.create(text: params[:text])
    current_user.tweets << tweet

    flash[:notice] = "Tweet envoyé !"
    redirect '/'
  else
    session[:unsaved_tweet] = params[:tweet]
    flash[:error] = "Veuillez vous connecter"
    redirect '/sign_in'
  end
end

get '/sign_up' do
  erb :sign_up
end

post '/users' do
  username = params[:username]
  password = params[:password]
  User.create(
    :username => username,
    :password => password
  )
  flash[:notice] = "Compte crée !"
  redirect '/sign_in'
end

get '/users' do
  @users = User.all
  erb :users
end

post '/follow' do
  username = params[:username]
  followed = User.find_by_username(username)

  current_user.friends << followed

  flash[:notice] = "Vous suivez maintenant #{followed.username}"
  redirect '/users'
end

post '/unfollow' do
  username = params[:username]
  unfollowed = User.find_by_username(username)

  current_user.friends.delete unfollowed

  flash[:notice] = "Vous ne suivez plus #{unfollowed.username}"
  redirect '/users'
end
