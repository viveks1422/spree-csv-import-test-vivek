# frozen_string_literal: true

class ProductImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(csv_file_path, admin_email)
    product_service = ProductService.new
    product_service.import_csv(csv_file_path, admin_email)
  rescue StandardError => e
    Rails.logger.info "*****Error**** in ProductImportWorker: #{e.message}"
  end
end
