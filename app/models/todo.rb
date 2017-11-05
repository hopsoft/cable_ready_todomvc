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
  validates :title, presence: true
  validates :completed, presence: true

  scope :owned_by, -> (user_id) { where user_id: user_id }
  scope :completed, -> { where completed: true }
  scope :uncompleted, -> { where completed: false }

  def uncompleted?
    !completed?
  end
end
