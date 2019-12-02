# frozen_string_literal: true

class ProductMailer < ApplicationMailer
  # mailer to inform admin for completetion of import product CSV
  def products_import_completed(email, errors = {})
    @errors = errors
    @errors_html = errors.join('<br>')
    subject = 'Notification: Product CSV import completed.'
    mail to: email, subject: subject
    end
end
