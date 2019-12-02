class ProductImportWorker
  
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(csv_file_path, admin_email)
    begin
      product_service = ProductService.new
      product_service.import_csv(csv_file_path, admin_email)
    rescue StandardError => err
      Rails.logger.info "*****Error**** in ProductImportWorker: #{err.message}"
    end
  end
end