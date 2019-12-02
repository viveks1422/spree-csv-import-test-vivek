require 'csv'
class ProductService
	# import product from CSV file
	def import_csv(csv_file_path, admin_email)
					
		csv_import_error = []
	    begin
	      CSV.read(csv_file_path, headers: true, header_converters: ->(h) { h.try(:downcase) }, :col_sep => ";", skip_blanks: true).each_with_index do |row, index|

	      	# convert to hash
	      	csv_has_row = row.to_hash
	      	# parameterize name for SKU
	      	# sku = parameterize_string(csv_has_row["name"])
	      	next if (trim_string(csv_has_row["name"]).blank? || trim_string(csv_has_row["category"]).blank?)
	      	#Shipping category we can set to any shipping category if present in CSV file but as in CSV there is no shiiping category we can use default
	      	shipping_category_id = Spree::ShippingCategory.find_or_create_by(name: 'Default').try(:id)
	      	#Prototype setting
	      	# stripe taxonomy name
	      	category_name = trim_string(csv_has_row["category"])
	      	spree_prototype = Spree::Prototype.find_or_create_by(name: category_name)
	      	# stripe taxonomy name
	      	taxonomy_name = category_name
	      	permalink = parameterize_string(csv_has_row["category"])
	      	#create taxonomy or find if it's already present
	      	taxonomy = Spree::Taxonomy.find_or_create_by(name: taxonomy_name)
	      	#create taxon or find if it's already present
	      	taxon = taxonomy.taxons.find_or_create_by(name: taxonomy_name, permalink: permalink)
	      	product_name = trim_string(csv_has_row["name"])
	      	product_description = trim_string(csv_has_row["description"])
	      	product_slug = trim_string(csv_has_row["slug"])
	      	product_availability_date = trim_string(csv_has_row["availability_date"])
	      	product_price = trim_string(csv_has_row["price"]).try(:to_f)
	      	# finding product
	        spree_product=Spree::Product.find_or_initialize_by({:name=>product_name})
	        # updating attributes
	        spree_product.update_attributes({name: product_name, price: product_price, description: product_description, slug: product_slug, available_on: product_availability_date, shipping_category_id: shipping_category_id})
	        # add taxons to product
			spree_product.taxons << taxon unless spree_product.taxon_ids.include?(taxon.id)
			spree_product.save
			#developer note Enable this to set properties for product
			#spree_product.set_property("property#{index}", csv_has_row['property'])
			#Setting up Option type for variants we can also this according to CSV most commnly are Color and Size
			color=Spree::OptionType.find_or_create_by({presentation: "Color", name: "color-#{permalink}"})
			size=Spree::OptionType.find_or_create_by({presentation: "Size", name: "size-#{permalink}"})
			#product option type	
			Spree::ProductOptionType.find_or_create_by({:product_id=>spree_product.id,:option_type_id=>color.id})
				Spree::ProductOptionType.find_or_create_by({:product_id=>spree_product.id,:option_type_id=>size.id})
			#Product variant
			option_values = default_option_values(color.id, size.id)

			option_values.each do |option_value|
				variant_sku = "#{spree_product.id}-#{parameterize_string(option_value[:name])}"
				spree_variant=Spree::Variant.find_or_initialize_by({:product_id=>spree_product.id,:sku=>variant_sku})
				# Cost currency
				spree_variant.cost_currency = 'USD' # Developer note: CSV column can be added csv_has_row["currency"]
				spree_product.update_attribute(:cost_currency,'USD') # Developer note cost current can be updated to spree product
				# spree_variant.cost_price = variant["original_price"]
				# spree_variant.price = csv_has_row["discount_price"] # Developer note: CSV column can be added csv_has_row["discount_price"]
				spree_variant.save(validate: false)
				# Stock items
				sti=spree_variant.stock_items.first_or_initialize
				sti.backorderable = false
				sti.count_on_hand = trim_string(csv_has_row["stock_total"])

				Spree::OptionValueVariant.find_or_create_by({:option_value_id=>option_value.id,:variant_id=>spree_variant.id})
				spree_variant.save!					
			end
	        # pushing row error to array
	        csv_import_error.push("Row: #{index + 1} #{spree_product.errors.full_messages.join(', ')}") if spree_product.errors.present?
	      end
	    rescue StandardError => err
	      csv_import_error.push(err.message)
	    end
	    import_errors = csv_import_error
	    #Notification email when import complated
	    ProductMailer.products_import_completed(admin_email, import_errors).deliver!
	    #Live push notificaiton
	end

	def trim_string(input_string)
		input_string.try(:strip)
	end

	def parameterize_string(input_string)
		input_string.try(:parameterize)	
	end

	def default_option_values(color_id, size_id)
		# Default option type value
		[{name: "Small", presentation: 'S', option_type_id: size_id}, {name: "Medium", presentation: 'M', option_type_id: size_id}, {name: "Large", presentation: 'L', option_type_id: size_id}, {name: "Extra Large", presentation: 'XL', option_type_id: size_id}, {name: "Red", presentation: "Red", option_type_id: color_id}, {name: "Green", presentation: "Green", option_type_id: color_id}, {name: "Blue", presentation: 'Blue', option_type_id: color_id}].collect{|option_value_hash| Spree::OptionValue.find_or_create_by(option_value_hash)}
	end

end