class Sessions::CasController < ApplicationController

  skip_before_filter :authenticate_user!

  def new
    redirect_to user_omniauth_authorize_path(:cas)
  end

  def no_authorization
    render :inline => "You are not authorized"
  end

  def destroy
    sign_out
    #redirect_to "#{Errbit::Config::cas_server}/logout?service=" + new_user_session_url
    render :inline => "You are now logged out"
    #flash[:notice] = "You have been logged out"
  end

  def cas 
    # You need to implement the method below in your model
    #render :inline => "<pre>#{env.inspect}"
    #return

    if @user = User.find_for_cas_oauth(env["omniauth.auth"], current_user)
      logger.info("PERSISTED")
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "CAS"
      sign_in_and_redirect @user, :event => :authentication
    else
      redirect_to no_authorization_path
    end
  end
end

