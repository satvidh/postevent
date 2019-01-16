import 'securerandom'

class SessionsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end

  def slack
    association_nonce = nonce
    association = Associations.
    flash.now.alert = "Login to associate slack user"
    render "new"
  end

private:
    def nonce
        SecureRandom.hex()
    end
end