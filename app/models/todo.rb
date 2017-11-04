# == Schema Information
#
# Table name: todos
#
#  id         :integer          not null, primary key
#  user_id    :string           not null
#  title      :string           not null
#  completed  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Todo < ApplicationRecord
  # extends ...................................................................
  # includes ..................................................................
  # relationships .............................................................

  # validations ...............................................................
  validates :title, presence: true

  # callbacks .................................................................

  # scopes ....................................................................
  scope :owned_by, -> (user_id) { where user_id: user_id }
  scope :completed, -> { where completed: true }
  scope :uncompleted, -> { where completed: false }

  # additional config (i.e. accepts_nested_attribute_for etc...) ..............
  # class methods .............................................................

  # public instance methods ...................................................
  def uncompleted?
    !completed?
  end

  # protected instance methods ................................................
  # private instance methods ..................................................
end
