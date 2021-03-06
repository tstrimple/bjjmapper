FactoryGirl.define do
  factory :user do
    sequence :name do |i|
      "Test User #{i}"
    end
    uid '1234'
    email 'test@rollfindr.com'
    provider :twitter
    image 'https://commondatastorage.googleapis.com/bjjmapper/image.png'
    image_large 'https://commondatastorage.googleapis.com/bjjmapper/large.png'
    image_tiny 'https://commondatastorage.googleapis.com/bjjmapper/tiny.png'
    ip_address '24.222.58.100'

    factory :white_belt do
      belt_rank 'white'
    end
    factory :blue_belt do
      belt_rank 'blue'
    end
    factory :purple_belt do
      belt_rank 'blue'
    end
    factory :black_belt do
      belt_rank 'black'
    end

    factory :instructor_with_students do
      after(:create) do |instance|
        3.times do
          instance.lineal_children << create(:user)
        end
      end
    end
  end
end
