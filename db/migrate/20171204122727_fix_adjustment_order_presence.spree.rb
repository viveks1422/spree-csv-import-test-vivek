# frozen_string_literal: true

# This migration comes from spree (originally 20141101231208)
class FixAdjustmentOrderPresence < ActiveRecord::Migration[4.2]
  def change
    say 'Fixing adjustments without direct order reference'
    Spree::Adjustment.where(order: nil).find_each do |adjustment|
      adjustable = adjustment.adjustable
      if adjustable.is_a? Spree::Order
        adjustment.update_attributes!(order_id: adjustable.id)
      else
        adjustment.update_attributes!(adjustable: adjustable.order)
      end
    end
  end
end
