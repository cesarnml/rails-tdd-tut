FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "user#{n}" }
    sequence(:name) { |n| "My Name #{n}" }
    sequence(:url) { |n| "http://example.com/#{n}" }
    sequence(:avatar_url) { |n| "http://example.com/avatar/#{n}" }
    provider { 'github' }
  end
end
