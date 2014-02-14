FactoryGirl.define do
  factory :topic do
    sequence(:slug) {|n| "test-topic-#{n}" }
    name 'Test Topic'
    record_count 42
  end
end
