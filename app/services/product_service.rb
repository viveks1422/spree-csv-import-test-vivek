# frozen_string_literal: true

require 'csv'
class ProductService
  # import product from CSV file
  def import_csv(csv_file_path, admin_email)
    csv_import_error = []
    begin
      # Developer note: You can use CSV parse file read or can use col_sep: ';' in case of diff col seperator
      CSV.read(csv_file_path, headers: true, header_converters: ->(h) { h.try(:downcase) }, skip_blanks: true).each_with_index do |row, index|
        # convert to hash
        csv_has_row = row.to_hash
        # parameterize name for SKU
        # sku = parameterize_string(csv_has_row["name"])
        if trim_string(csv_has_row['name']).blank? || trim_string(csv_has_row['category']).blank?
          next
       end

        # Shipping category we can set to any shipping category if present in CSV file but as in CSV there is no shiiping category we can use default
        row_shipping_category = trim_string(csv_has_row['shipping_category'].try(:capitalize)) || 'Default'
        shipping_category_id = Spree::ShippingCategory.find_or_create_by(name: row_shipping_category).try(:id)
        # Prototype setting
        # stripe taxonomy name
        category_name = trim_string(csv_has_row['category'])
        spree_prototype = Spree::Prototype.find_or_create_by(name: category_name)
        # stripe taxonomy name
        taxonomy_name = category_name
        permalink = parameterize_string(csv_has_row['category'])
        # create taxonomy or find if it's already present
        taxonomy = Spree::Taxonomy.find_or_create_by(name: taxonomy_name)
        # create taxon or find if it's already present
        taxon = taxonomy.taxons.find_or_create_by(name: taxonomy_name, permalink: permalink)
        product_name = trim_string(csv_has_row['name'])
        product_description = trim_string(csv_has_row['description'])
        product_slug = trim_string(csv_has_row['slug'])
        product_availability_date = trim_string(csv_has_row['availability_date'])
        product_price = trim_string(csv_has_row['price']).try(:to_f)
        product_currency = trim_string(csv_has_row['currency'].try(:upcase)) || 'USD'
        cost_price = trim_string(csv_has_row['cost_price']).try(:to_f)
        variant_color = trim_string(csv_has_row['color'])
        variant_size = trim_string(csv_has_row['size'])
        row_stock_location = trim_string(csv_has_row['stock_location']) || 'default'
        # finding product
        spree_product = Spree::Product.find_or_initialize_by(slug: product_slug)
        # updating attributes
        spree_product.update_attributes(name: product_name, price: product_price, description: product_description, available_on: product_availability_date, shipping_category_id: shipping_category_id, cost_currency: product_currency)
        # add taxons to product
        unless spree_product.taxon_ids.include?(taxon.id)
          spree_product.taxons << taxon
       end
        spree_product.save!
        # developer note Enable this to set properties for product
        # spree_product.set_property("property#{index}", csv_has_row['property'])
        # Setting up Option type for variants we can also this according to CSV most commnly are Color and Size I assume there are only color and size we can change this according to requirements
        color = Spree::OptionType.find_or_create_by(presentation: 'Color', name: "color-#{permalink}")
        size = Spree::OptionType.find_or_create_by(presentation: 'Size', name: "size-#{permalink}")
        # product option type
        Spree::ProductOptionType.find_or_create_by(product_id: spree_product.id, option_type_id: color.id)
        Spree::ProductOptionType.find_or_create_by(product_id: spree_product.id, option_type_id: size.id)
        # Product variant
        if variant_color.present? || variant_color.present?
          option_values = option_value_by_csv(color.id, size.id, variant_color, variant_size)
        else
          option_values = default_option_values(color.id, size.id)
          # option_values = []
        end
        # option_values = option_value_by_csv(color_id, size_id, row_color, row_size)
        option_values.each do |option_value|
          variant_sku = "#{spree_product.id}-#{parameterize_string(option_value[:name])}"
          spree_variant = Spree::Variant.find_or_initialize_by(product_id: spree_product.id, sku: variant_sku)
          # stock location
          stock_location = Spree::StockLocation.find_or_create_by(name: row_stock_location) # this we can set via CSV file
          # Cost currency
          spree_variant.cost_currency = product_currency # Developer note: CSV column can be added csv_has_row["currency"]
          # spree_product.update_attribute(:cost_currency, product_currency) # Developer note cost current can be updated to spree product
          spree_variant.cost_price = cost_price if cost_price.present?
          # spree_variant.price = csv_has_row["discount_price"] # Developer note: CSV column can be added csv_has_row["discount_price"]
          spree_variant.save(validate: false)
          # Stock items
          sti = spree_variant.stock_items.first_or_initialize
          sti.backorderable = false
          sti.count_on_hand = trim_string(csv_has_row['stock_total'])
          # setting up stock location id
          sti.stock_location_id = stock_location.id
          sti.save

          Spree::OptionValueVariant.find_or_create_by(option_value_id: option_value.id, variant_id: spree_variant.id)
          # spree_variant.save!
        end
        # pushing row error to array
        if spree_product.errors.present?
          csv_import_error.push("Row: #{index + 1} #{spree_product.errors.full_messages.join(', ')}")
      end
      end
    rescue StandardError => e
      csv_import_error.push(e.message)
    end
    import_errors = csv_import_error
    # Notification email when import complated
    ProductMailer.products_import_completed(admin_email, import_errors).deliver!
    # Live push notificaiton
    # Developer note: we can use this live notification
    # ActionCable.server.broadcast('notification_channel', notification_data: {
    #                               message: "CSV Import is completed please check your email by email.",
    #                               alert_class: 'alert-info'
    #                             });

    { success: import_errors.blank?, errors: import_errors }
  end

  def trim_string(input_string)
    input_string.try(:strip)
  end

  def parameterize_string(input_string)
    input_string.try(:parameterize)
  end

  # This method is for default demo purpose if CSV variants columns are missing
  def default_option_values(color_id, size_id)
    # Default option type value
    [{ name: 'Small', presentation: 'S', option_type_id: size_id }, { name: 'Medium', presentation: 'M', option_type_id: size_id }, { name: 'Large', presentation: 'L', option_type_id: size_id }, { name: 'Extra Large', presentation: 'XL', option_type_id: size_id }, { name: 'Red', presentation: 'Red', option_type_id: color_id }, { name: 'Green', presentation: 'Green', option_type_id: color_id }, { name: 'Blue', presentation: 'Blue', option_type_id: color_id }].collect { |option_value_hash| Spree::OptionValue.find_or_create_by(option_value_hash) }
  end

  def option_value_by_csv(color_id, size_id, row_color, row_size)
    option_value_array = []
    # row color variants
    if row_color.present?
      row_color_variant = row_color.split(':')
      # pushing values
      option_value_array.push(name: trim_string(row_color_variant.first).try(:capitalize), presentation: trim_string(row_color_variant.last).try(:capitalize), option_type_id: color_id)
    end
    # row size variants
    if row_size.present?
      row_size_variant = row_size.split(':')
      # pushing values
      option_value_array.push(name: trim_string(row_size_variant.first).try(:capitalize), presentation: trim_string(row_size_variant.last).try(:capitalize), option_type_id: size_id)
    end
    # Creating option value
    option_value_array.collect { |option_value_hash| Spree::OptionValue.find_or_create_by(option_value_hash) }
  end

  def is_valid_csv?(csv_file_path)
    csv_file_path.split('.').last.to_s.downcase == 'csv'
  end
end
