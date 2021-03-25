# frozen_string_literal: true

class Submission < ApplicationRecord
  belongs_to :place, optional: true

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true, on: :create
  validates :rights, inclusion: [true]
  validates :privacy, inclusion: [true]
  validates :locale, presence: true
end
