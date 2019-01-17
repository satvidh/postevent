require 'securerandom'
require 'slack-ruby-client'
require 'logger'

class SessionsController < ApplicationController
  def new
    logger.debug("Remove nonce from session")
    session[:nonce] = nil
    render "new"
  end
  def create
    logger.debug("Remove nonce from session")
    session[:nonce] = nil
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      association_nonce = params[:nonce]
      if not association_nonce.nil? and not association_nonce.empty?
          association = Associations.find_by_nonce(association_nonce)
          time_now = Time.now
          logger.info("expiration time #{association.nonce_expiration_time} and now #{time_now}")
          if not association or time_now >= association.nonce_expiration_time
            render "slack_expired_nonce" and return
          else
            association.update_attributes(:nonce_expiration_time => Time.now)
            user.update_attributes(:slack_user_id => association.user_id)
            flash.now.alert = "Successfully connected slack to PostEvent."
          end
      end
      session[:user_id] = user.id
      redirect_to root_url
    else
      session[:nonce] = params[:nonce]
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end

  def connect_slack
    association_nonce = params[:nonce]
    association = Associations.find_by_nonce(association_nonce)
    if association and Time.now < association.nonce_expiration_time
        user = User.find_by_slack_user_id(association.user_id)
        if not user
          flash.now.alert = "Log in to link slack user to PostEvent"
          session[:nonce] = association_nonce
          render "new"
          logger.debug("Remove nonce from session")
          session[:nonce] = nil
        else
          association.update_attributes(:nonce_expiration_time => Time.now)
          session[:user_id] = user.id
          logger.debug("Redirect to root with user_id #{session[:user_id]}")
          redirect_to :controller => "events", :action => "new"
        end
    else
        render "slack_expired_nonce"
    end
  end
end