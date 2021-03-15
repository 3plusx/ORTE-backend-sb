# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  protect_from_forgery with: :exception

  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # def default_url_options(options = {})
  #   logger.debug "default_url_options is passed options: #{options.inspect}\n"
  #   { locale: I18n.locale }
  # end

  def report_csp
    # do nothing right now...
  end
end
