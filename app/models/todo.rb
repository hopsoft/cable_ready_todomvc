class Todo < ApplicationRecord
  validates :title, presence: true
  validates :completed, presence: true

  scope :owned_by, -> (user_id) { where user_id: user_id }
  scope :completed, -> { where completed: true }
  scope :uncompleted, -> { where completed: false }

  def uncompleted?
    !completed?
  end
end
