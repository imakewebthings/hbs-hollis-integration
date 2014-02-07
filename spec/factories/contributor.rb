FactoryGirl.define do
  factory :contributor do
    name 'Jane Test'
    role 'HBS Faculty'
    primary_unit 'Test Unit'
    sequence :person_id
    title 'Test Title'
    sequence(:name_slug) {|n| "jane-test-#{n}" }
    primary_unit_slug 'test-unit'
  end
end
