require 'securerandom'
require 'slack-ruby-client'

class SessionsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      association_nonce = params[:nonce]
      if association_nonce
          association = Associations.find_by_nonce(association_nonce)
          if not association or Time.now >= association.nonce_expiration_time
            render "slack_expired_nonce"
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
        association.update_attributes(:nonce_expiration_time => Time.now)
        user = User.find_by_slack_user_id(association.user_id)
        if not user
          flash.now.alert = "Log in to link slack user to PostEvent"
          session[:nonce] = association_nonce
          render "new"
        end
    else
        render "slack_expired_nonce"
    end
  end

  def get_post_link
    slack_user_id = params[:user_id]
    association_nonce = nonce
    association = Associations.new(:user_id => slack_user_id,
                                   :nonce => association_nonce,
                                   :nonce_expiration_time => 5.minutes.from_now)
    association.save
    # Check if user is already associated
    user = User.find_by_slack_user_id(slack_user_id)
    if not user
        link = "https://#{request.host_with_port}/session/connect/slack?nonce=#{association.nonce}"
        attachments = [
            {
                fallback: "Click #{link}",
                actions: [
                    {
                        type: "button",
                        text: "Link slack user to PostEvent",
                        url: link
                    }
                ]
            }
        ]
        text = "You have not connected your slack account to your PostEvent login."
    end
    client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
    client.auth_test
    client.chat_postEphemeral(channel: slack_user_id,
                              text: text,
                              user: slack_user_id,
                              attachments: attachments)
    "Slack user not connected."
  end

private

    def nonce
        SecureRandom.hex()
    end
end