FactoryGirl.define do
  factory :directory_segment do
    name 'Canada'
    description 'A short test description'
    coordinates [80.0, 80.0]
    flag_index_visible true
  end
end
