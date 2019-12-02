class ProductImportWorker
  
  include Sidekiq::Worker

  def perform(csv_file_path, admin_email)
    csv_import_error = []
    begin
      CSV.foreach(filename.path, headers: true, header_converters: ->(h) { h.try(:downcase) }).each_with_index do |row, index|
        winner = @current_shop.winners.find_or_initialize_by(row.to_hash)
        csv_import_error.push("Row: #{index + 1} #{winner.errors.full_messages.join(', ')}") unless winner.save
      end
    rescue StandardError => err
      Rails.logger.info "*****Error**** in ProductImportWorker: #{err.message}"
    end
  end
end