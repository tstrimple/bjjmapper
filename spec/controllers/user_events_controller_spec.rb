require 'spec_helper'
require 'shared/tracker_context'

describe UserEventsController do
  include_context 'skip tracking'
  describe 'GET index' do
    let(:start_time) { 5.hours.ago.iso8601 }
    let(:end_date) { Time.now.iso8601 }
    let(:user) { create(:user) }
    let(:location) { create(:location) }
    context 'with date range' do
      context 'with matching events in date range' do
        before do
          create(:event, instructor: user, location: location, title: 'included event 123', starting: 2.hours.ago.to_i, ending: 1.hours.ago.to_i)
          create(:event, instructor: user, location: location, title: 'excluded event 456', starting: 10.hours.ago.to_i, ending: 9.hours.ago.to_i)
        end
        it 'returns events that are within the date range' do
          get :index, { user_id: user.to_param, format: 'json', start: start_time, end: end_date }
          assigns[:events].count.should eq 1
          assigns[:events].first.title.should eq 'included event 123'
        end
      end
      context 'with no matching events in date range' do
        it 'returns 204 no content' do
          get :index, { user_id: user.to_param, format: 'json', start: 99.hours.ago.iso8601, end: 100.hours.ago.iso8601 }
          response.status.should eq 204
        end
      end
    end
    context 'without date range' do
      it 'returns bad request' do
        get :index, { user_id: user.to_param, format: 'json', start: start_time }
        response.should_not be_ok
      end
    end
  end
end

