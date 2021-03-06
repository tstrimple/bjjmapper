require 'spec_helper'

describe RollFindr::LocationFetchClient do
  subject { RollFindr::LocationFetchClient.new('localhost', 443) }
  describe '.search' do
    context 'with success response' do
      let(:response) { double('http_response', code: 202) }
      before { Net::HTTP.any_instance.should_receive(:request).with(instance_of(Net::HTTP::Post)).and_return(response) }
      it 'fetches the response from the service' do
        subject.search('loc1234', {}).should eq 202
      end
    end
    context 'when the service is down' do
      before { Net::HTTP.any_instance.should_receive(:request).with(instance_of(Net::HTTP::Post)).and_raise(StandardError, 'service is down') }
      it 'returns 500' do
        subject.search('loc1234', {}).should eq 500
      end
    end
  end
  describe '.reviews' do
    context 'with success response' do
      let(:expected_response) { { reviews: [], rating: 4.7, review_summary: 'fantastic' }.to_json }
      let(:response) { double('http_response', :code => 200, :body => expected_response) }
      before { Net::HTTP.any_instance.should_receive(:request).with(instance_of(Net::HTTP::Get)).and_return(response) }
      it 'returns the response' do
        subject.reviews('loc1234').should eq JSON.parse(expected_response).deep_symbolize_keys
      end
    end
    context 'with failure response' do
      let(:response) { double('http_response', :code => 400, :body => '{}') }
      before { Net::HTTP.any_instance.should_receive(:request).with(instance_of(Net::HTTP::Get)).and_return(response) }
      it 'returns nil' do
        subject.reviews('loc1234').should be_nil
      end
    end
    context 'when the service is down' do
      before { Net::HTTP.any_instance.should_receive(:request).and_raise(StandardError, 'service is down') }
      it 'returns nil' do
        subject.reviews('loc1234').should be_nil
      end
    end
  end
  describe '.listings' do
    context 'with success response' do
      let(:response) { double('http_response', :code => 200, :body => '{}') }
      before { Net::HTTP.any_instance.should_receive(:request).and_return(response) }
      it 'returns the response' do
        subject.listings('loc1234').should_not be_nil
      end
    end
    context 'with failure response' do
      let(:response) { double('http_response', :code => 400, :body => '{}') }
      before { Net::HTTP.any_instance.should_receive(:request).and_return(response) }
      it 'returns nil' do
        subject.listings('loc1234').should be_nil
      end
    end
    context 'when the service is down' do
      before { Net::HTTP.any_instance.should_receive(:request).and_raise(StandardError, 'service is down') }
      it 'returns nil' do
        subject.listings('loc1234').should be_nil
      end
    end
  end
end
