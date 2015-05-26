require 'spec_helper'
require 'shared/tracker_context'

describe UsersController do
  include_context 'skip tracking'
  describe 'GET reviews' do
    context 'with json format' do
      let(:user) { create(:user) }
      let(:location) { create(:location) }
      before { create(:review, user: user, location: location) }
      it 'returns the recent reviews' do
        get :reviews, id: user.id, format: 'json', count: 1
        response.should be_success
        response.body.should match(user.reviews.first.decorate.to_json)
      end
    end
  end
  describe 'GET index' do
    context 'with html format' do
      before { create(:user, belt_rank: 'black') }
      it 'returns the grouped users' do
        get :index, { format: 'html' }
        response.should be_ok
      end
    end
  end
  describe 'GET show' do
    let(:user) { create(:user) }
    context 'with json format' do
      it 'returns the user' do
        get :show, id: user.id, format: 'json'
        response.body.should eq user.to_json
      end
    end
    context 'with html format' do
      it 'renders the show page' do
        get :show, id: user.id, format: 'html'
        response.should render_template('users/show')
      end
    end
  end
  describe 'POST create' do
    let(:anonymous_user) { create(:user, role: 'anonymous') }
    let(:session_params) { { :user_id => anonymous_user.to_param } }
    let(:create_params) { { :user => { :name => 'Buddy', :email => 'buddy@hotmale.com', :belt_rank => 'purple', :stripe_rank => 3 } } }
    context 'with html format' do
      it 'creates and redirects to a new user in edit mode' do
        anonymous_user
        expect do
          post :create, create_params.merge({:format => 'html'}), session_params
          response.should redirect_to(user_path(assigns(:user), edit: 1, create: 1))
        end.to change { User.count }.by(1)
      end
    end
    context 'with json format' do
      it 'creates and returns a new user' do
        post :create, create_params.merge({:format => 'json'}), session_params
        response.body.should match(create_params[:user][:name])
      end
    end
  end
  describe 'POST update' do
    let(:user) { create(:user, name: 'Buddy') }
    let(:update_params) { { :user => { :name => 'Buddy Holly' } } }
    context 'when the user is not editable' do
      before { User.any_instance.stub(:editable_by?).and_return(false) }
      it 'returns forbidden' do
        post :update, { id: user.id }.merge(update_params)
        response.status.should eq 403
      end
    end
    context 'with json format' do
      before { User.any_instance.stub(:editable_by?).and_return(true) }
      it 'updates and returns the user' do
        post :update, { id: user.id, :format => 'json' }.merge(update_params)
        response.body.should match update_params[:user][:name]
      end
    end
    context 'with html format' do
      before { User.any_instance.stub(:editable_by?).and_return(true) }
      it 'redirects back to the location' do
        post :update, { id: user.id, :format => 'html' }.merge(update_params)
        response.body.should redirect_to(user_path(user, edit: 0))
      end
    end
  end
end

