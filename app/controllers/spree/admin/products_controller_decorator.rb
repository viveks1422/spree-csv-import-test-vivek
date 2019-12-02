Spree::Admin::ProductsController.class_eval do
    # Developer note: adding actions for import csv for products
    def import_csv
		respond_to do |format|
			format.html
		end      
    end

    def upload_csv
    	respond_to do |format|
    		format.html {
                product_service = ProductService.new
                product_service.import_csv(params[:csv_file].path, current_spree_user.try(:email))
    			redirect_to admin_products_path, notice: 'CSV Import is in progress, once it gets completed notification will be sent by email.'
    		}
    	end
    end
end