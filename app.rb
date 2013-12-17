require "sinatra"
require "sinatra/activerecord"
require 'digest/sha2'
require 'sinatra/flash'
require_relative './helpers/posting'
helpers Posting
Dir.foreach('models/') { |model| require "./models/#{model}" if model.match /.rb$/ }


configure do
  enable :sessions
  set :session_secret, 'secret'
end


get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end


get "/posts/new" do
  @title = "New Post"
  @post = Post.new
  erb :"posts/new"
end


post "/posts/:id/create_comment" do
  @post = Post.find(params[:id])
  valid_comment
  @comm = Comment.new( 
                      body: params[:body], 
                      post_id: params[:id], 
                      user_name: session[:name], 
                      user_id: session[:user_id])
  @comm.save
  redirect "/posts/#{@comm.post_id}"
end


post "/posts" do
  valid_post
  flash[:title] = params[:title]  
  user_id = session[:user_id]
  @post = Post.new(title: params[:title], body: params[:body], user_id: user_id)
  if @post.save
    redirect "posts/#{@post.id}"
  else
    redirect '/posts/new'
    flash[:errors] = post.errors.message
  end
end
 

get "/posts/:id" do
  @post = Post.find params[:id]
  erb :"posts/show"
end


get "/posts/:id/edit" do
  @post = Post.find params[:id]
  @title = "Edit Form"
  erb :"posts/edit"
end
 

put "/posts/:id" do
  @post = Post.find params[:id]
  if @post.update_attributes(params[:post])
    redirect "/posts/#{@post.id}"
  else
    erb :"posts/edit"
  end
end

delete "/posts/:id/comment/:id_comment" do
   @post = Post.find(params[:id])  
   if author? @post
      @comm = Comment.find(params[:id_comment]).destroy
      redirect "/posts/#{@comm.post_id}"
   end
end

delete "/posts/:id" do
  @post = Post.find params[:id]  
  if author? @post 
    @post = Post.find(params[:id]).destroy
  end
  redirect "/"
end

get "/about" do
  @title = "About Me"
  erb :"pages/about"
end

get "/signup" do
  @title='Sign up'
  @user = User.new
  erb :'registration/register'      
end

post '/signup' do
  @user = User.new(user_params)
  if User.is_persisted?(params[:email])
    @user.valid?
    erb :'registration/register'
  else
    @user.password_second = params[:password_second]
    @user.save 
    unless @user.errors.empty?
      erb :'registration/register'
    else
      redirect '/enter'
    end
  end
end


post '/signin' do
  password = Digest::SHA2.hexdigest(params[:password] + User::SALT)
  user = User.find_by(email: params[:email], password: password)
  if user    
    session[:name] = user.name
    session[:email]= user.email
    session[:user_id] = user.id
    session[:all]  = user, password
    redirect '/'
  end
  redirect '/'
end

get '/enter' do
  erb :'registration/enter'
end

post '/logout' do
  session.clear
  redirect '/'
end 

def user_params
  permit params, :name, :email, :password
end

def permit hash, *keys #filters hash for unavailable parameters
  result = {}
  keys.each { |k| result[k] = hash[k] }
  result 
end