require 'spec_helper'

describe LocationReviews do
  subject { LocationReviews.new('location-id') }
  let(:local_review_rating) { 3.0 }
  before { Review.stub(:where).and_return([build(:review, rating: local_review_rating, location: nil, user: nil)]) }


  let(:service_rating) { 5.0 }
  let(:service_response) { { reviews: [{body: 'test'}], rating: service_rating } }
  before { ::RollFindr::LocationFetchService.stub(:reviews).and_return(service_response) }
  describe '.items' do
    it 'returns an array of local and remote (locationfetchsvc) reviews for the location' do
      subject.items.count.should eq 2
    end
  end
  describe '.rating' do
    it 'returns a rating average' do
      subject.rating.should eq ((service_rating + local_review_rating) / 2.0)
    end
  end
end
