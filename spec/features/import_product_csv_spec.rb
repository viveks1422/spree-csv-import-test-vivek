# frozen_string_literal: true

require 'rails_helper'
RSpec.feature 'Import Product CSV', type: :feature do
  before(:all) do
    @spree_admin = create(:spree_user)
    @spree_admin.add_spree_role :admin
  end
  # before(:each) do
  #   sign_in @spree_admin
  # end
  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  describe "Testing spree product CSV import" do
    context 'Admin user login, import product CSV and logout' do
      scenario 'Goto sigin page to login as admin goto dashboard and upload sample.csv to import products and variants' do
        visit '/login'
        expect(page).to have_content('Login as Existing Customer')
        within find('#new_spree_user') do
          fill_in 'spree_user_email', with: @spree_admin.email.to_s
          fill_in 'spree_user_password', with: @spree_admin.password.to_s
        end
        click_button 'commit'
        expect(current_path).to eq('/')
        expect(page).to have_text('Logged in successfully')
        # Visit admin products page there you will see option for CSV import
        visit '/admin/products'
        click_link('import_csv_product')
        expect(current_path).to eq('/admin/import_csv')
        #select CSV
        within find('#upload_product_csv') do
          attach_file('csv_file', Rails.root + 'sample.csv')
        end
        click_button 'Import'
        expect(page).to have_content('CSV product was updated successfully')
        spree_products = Spree::Product.all
        #To check product uploaded successfully
        expect(spree_products.size).to eq(3)
        # To test email delivery
        action_mailer = ActionMailer::Base.deliveries
        expect(action_mailer.size).to eq(1)
        # check email subject line
        expect(action_mailer.first.subject).to eq('Notification: Product CSV import completed.')
        click_on(class: 'dropdown-toggle')
        # Logout
        click_link 'Logout'
        expect(current_path).to eq('/')
        expect(page).to have_text('Signed out successfully.')
      end
    end
  end
end
