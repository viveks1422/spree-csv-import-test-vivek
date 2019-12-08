# frozen_string_literal: true

Spree::Admin::ProductsController.class_eval do
  # Developer note: adding actions for import csv for products
  def import_csv
    respond_to do |format|
      format.html
    end
  end

  def upload_csv
    respond_to do |format|
      format.html do
        csv_file_path = params[:csv_file].path
        product_service = ProductService.new
        # CSV file validation
        if product_service.is_valid_csv?(csv_file_path)
          admin_email = current_spree_user.try(:email)
          if Rails.env.test? || Rails.env.development?
            csv_import_resp = product_service.import_csv(csv_file_path, admin_email)
            if csv_import_resp[:errors].present?
              flash[:error] = csv_import_resp[:errors].join(', ')
            else
              flash[:notice] = 'CSV product was updated successfully'
            end
          else
            ProductImportWorker.perform_async(csv_file_path, admin_email)
            flash[:notice] = 'CSV Import is in progress, once it gets completed notification will be sent by email.'
          end
        else
          flash[:error] = 'Wrong file format. Please upload CSV file.'
        end
        redirect_to admin_products_path
      end
    end
  end
end
