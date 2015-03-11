# == Schema Information
#
# Table name: cat_rental_requests
#
#  id         :integer          not null, primary key
#  cat_id     :integer
#  start_date :date             not null
#  end_date   :date             not null
#  status     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'byebug'



class CatRentalRequest < ActiveRecord::Base
  validates :cat_id, :start_date, :end_date, presence: true
  validates :status, inclusion: { in: %w(PENDING APPROVED DENIED) }
  validate :overlapping_approved_requests
  validate :validate_start_date, :validate_end_date, :start_not_after_end
  after_initialize :set_pending

  belongs_to :cat

  def approve!
    self.transaction do
      self.status = "APPROVED"
      self.save
      overlapping_requests.each do |request|
        request.deny!
      end
    end
  end

  def deny!
    self.status = "DENIED"
    self.save
  end

  private

  def set_pending
    # status ||= update_attributes(status: 'PENDING')
    self.status ||= "PENDING"
  end

  def start_not_after_end
    if start_date > end_date
      errors.add(:start_date, "can't be after end date")
    end
  end

  def validate_start_date
    validate_date_thing(:start_date, start_date)
  end

  def validate_end_date
    validate_date_thing(:end_date, end_date)
  end

  def validate_date_thing(attribute, date)
    if changed_attributes[attribute] && changed_attributes[attribute] < Date.today
      errors.add(attribute, 'cannot be changed')
    elsif date < Date.today
      errors.add(attribute, 'cannot be set before today')
    end
  end

  def overlapped?(other_request)
    date_range = (start_date..end_date)
    date_range.include?(other_request.end_date) || date_range.include?(other_request.start_date)
  end

  def all_requests_for_cat
    self.class.where(cat_id: cat_id)
  end

  def overlapping_approved_requests
    return unless status == "APPROVED"
    all_requests_for_cat.where(status: 'APPROVED').each do |request|
      if overlapped?(request)
        errors.add(:request, 'conflicts with already approved request')
      end
    end
  end

  def overlapping_requests
    all_requests_for_cat.where(status: 'PENDING').select do |request|
      overlapped?(request)
    end
  end
end
