# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'info@spree.com'
  layout 'mailer'
end
