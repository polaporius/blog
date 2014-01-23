require "sinatra"
require 'rubygems'
require "sinatra/activerecord"
require 'sinatra/flash'
require "digest/sha2"

Dir.foreach('models/') { |model| require "./models/#{model}" if model.match /.rb$/ }
Dir.foreach('./helpers/') { |model| require_relative "./helpers/#{model}" if model.match /.rb$/ }
helpers Posting


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
  @comm = Comment.new(title: params[:title],
                      body: params[:body],
                      post_id: params[:id],
                      user_name: session[:all].name,
                      user_id: session[:all].id)
  @comm.save
  unless @comm.errors.empty?
    @comm.valid?
    erb :"posts/show"
  else
    redirect "/posts/#{params[:id]}"
  end
end


post "/posts" do  
  @post = Post.new(title: params[:title], body: params[:body], user_id: session[:all].id)
  @post.save
  unless @post.errors.empty?
    @post.valid?
    erb :"posts/new"
  else
    redirect "posts/#{@post.id}"
  end
end
 

get "/posts/:id" do
  @post = Post.find(params[:id])
  erb :"posts/show"
end


get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  @title = "Edit Form"
  erb :"posts/edit"
end
 

put "/posts/:id" do
  @post = Post.find(params[:id])
  if author? @post
    if @post.update_attributes(params[:post]) 
      redirect "/posts/#{@post.id}"
    else
      erb :"posts/edit"
    end
  end
end


delete "/posts/:id/comment/:id_comment" do
  @comm = Comment.find(params[:id_comment])  
  if author? @comm.post
    @comm = Comment.find(params[:id_comment]).destroy
    redirect "/posts/#{params[:id]}"
  end
end


delete "/posts/:id" do
  @post = Post.find(params[:id])  
  if author? @post 
    @post.destroy
    redirect "/"
  end
end


get "/about" do
  @title = "About Me"
  erb :"pages/about"
end


post '/signup' do
  @user = User.new(name: params[:name], email: params[:email], password: params[:password])
  if User.is_persisted?(params[:email])
    @user.valid?
    erb :'registration/register'
  else
    @user.password_second = params[:password_second]
    @user.save 
    unless @user.errors.empty?
      @user.valid?
      erb :'registration/register'
    else
      redirect '/enter'
    end
  end
end


post '/signin' do
  @user_check = User.new(password: params[:password])
  @user_check = @user_check.hash
  @user = User.find_by_email(params[:email])
  if User.is_persisted?(params[:email]) && @user_check == @user.password
    session[:all] = @user
    redirect '/'
  else
    flash[:error]="check email or password"
    redirect '/'
  end
end


get '/enter' do
  erb :"registration/enter"
end


get "/reg" do
  @title='Sign up'
  erb :"registration/register"      
end


post '/logout' do
  session.clear
  redirect '/'
end 