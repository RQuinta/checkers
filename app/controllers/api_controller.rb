class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  respond_to :html, only: [:index]
  protect_from_forgery with: :exception

  def index
  end

end
