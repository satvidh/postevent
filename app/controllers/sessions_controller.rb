require 'logger'

class SessionsController < ApplicationController
  SLACK_ASSOCIATION_URI = '/associations/slack'
  def create
  	nonce = params[:nonce]
  	logger.debug("create called with nonce=#{nonce}")
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      if nonce
      	redirect_to "#{SLACK_ASSOCIATION_URI}?nonce=#{nonce}"
      else
      	redirect_to root_url
      end
    else
      flash.now.alert = "Invalid email or password"
      session[:nonce] = nonce
      render "new"
    end
  end

  def destroy
  	logger.debug("destroy called with nonce=#{params[:nonce]}")
  	nonce = params[:nonce]
    session[:user_id] = nil
    if nonce
    	session[:nonce] = nonce
    	flash[:notice] = "Log in to associate slack user!"
    	render "new"
    else
    	redirect_to root_url, :notice => "Logged out!"
    end
  end
end