class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :keepsafe
  
  protected
    def keepsafe
      request.local? || authenticate_or_request_with_http_digest do |username|
        Rails.config.users[username]
      end
    end
    
    def current_user=(user)
      session[:user_id] = user && user.id
    end
    
    def current_user
      session[:user_id] && User.find(session[:user_id])
    end
    
    def logged_in?
      !!current_user
    end
    
    def require_user
      unless current_user
        respond_to do |format|
          format.html do
            store_location
            redirect_to authorize_url          
          end
          
          format.all do
            head(:unauthorized)
          end
        end
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.fullpath
    end
    
    def redirect_back_or_default(default)
      return_to = session[:return_to] || params[:return_to]
      redirect_to(return_to.present? ? return_to : default)
      session[:return_to] = nil
    end
    
    helper_method :logged_in?, :current_user
end