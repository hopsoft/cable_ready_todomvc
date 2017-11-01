# == Schema Information
#
# Table name: rendered_pages
#
#  id         :integer          not null, primary key
#  user_id    :string           not null
#  name       :string           not null
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class RenderedPageTest < ActiveSupport::TestCase
end
