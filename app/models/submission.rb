# frozen_string_literal: true

class Submission < ApplicationRecord
  belongs_to :place, optional: true
end
