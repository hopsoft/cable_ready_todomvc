# == Schema Information
#
# Table name: todos
#
#  id         :integer          not null, primary key
#  title      :string           not null
#  completed  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Todo < ApplicationRecord
  # extends ...................................................................

  # includes ..................................................................
  include SelfRenderer

  # relationships .............................................................

  # validations ...............................................................
  validates :title, presence: true

  # callbacks .................................................................
  after_create do
  end

  # scopes ....................................................................
  scope :completed, -> { where completed: true }
  scope :uncompleted, -> { where completed: false }

  # additional config (i.e. accepts_nested_attribute_for etc...) ..............
  # class methods .............................................................

  # public instance methods ...................................................
  def uncompleted?
    !completed?
  end

  def hide?(filter)
    return true if filter == "Completed" && uncompleted?
    return true if filter == "Active" && completed?
    false
  end

  # protected instance methods ................................................
  # private instance methods ..................................................
end
