# frozen_string_literal: true

require 'ffaker'
FactoryBot.define do
  factory :spree_user, class: Spree::User do
    email { FFaker::Internet.email }
    password { 'spree123' }
    password_confirmation { 'spree123' }
  end
end
