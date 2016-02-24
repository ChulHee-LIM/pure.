class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  before_filter :set_rand_cookie

  private  
  def set_rand_cookie
    return if cookies[:rand_seed].present?
    cookies[:rand_seed] = {value: rand(100), expires: Time.now + 900}
  end
end
