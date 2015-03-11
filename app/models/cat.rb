# == Schema Information
#
# Table name: cats
#
#  id          :integer          not null, primary key
#  birthdate   :date
#  color       :string
#  name        :string           not null
#  sex         :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Cat < ActiveRecord::Base
  COLORS = %w(tabby calico grey black white striped)

  validates :color, inclusion: { in: COLORS }
  validates :name, :sex, presence: true
  validates :sex, inclusion: { in: %w(M F)}

  has_many :cat_rental_requests, dependent: :destroy

  def age
    years = (Date.today.year - birthdate.year)
    months = (Date.today.month - birthdate.month )
    if months < 0
      years -= 1
      months += 12
    end

    "#{years} years, #{months} months"
  end
end
