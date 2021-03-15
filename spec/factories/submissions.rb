# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    name { 'MyString' }
    email { '' }
    rights { false }
    privacy { false }
    locale { 'MyString' }
  end
end
