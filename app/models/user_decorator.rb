# frozen_string_literal: true

Spree::User.class_eval do
  # To add role to spree user
  def add_spree_role(role_name)
    role_name = role_name.try(:to_s).try(:strip).try(:parameterize)
    # retun with error is role_name is blank
    return errors.add(:role, 'Please mention role name.') if role_name.blank?

    # find or create spree role
    spree_role = Spree::Role.find_or_create_by(name: role_name)
    # add spree role
    Spree::RoleUser.find_or_create_by(role_id: spree_role.id, user_id: id)
  end
end
