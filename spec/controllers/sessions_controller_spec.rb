require 'spec_helper'
require 'shared/omniauth_context'

describe SessionsController do
  describe 'GET new' do
    it 'shows the signin page' do
      get :new
      response.should be_success
    end
  end
  describe 'POST create' do
    include_context 'omniauth success'
    context 'when the user does not exist' do
      it 'creates a user' do
        expect do
          post :create, provider: omniauth_provider
        end.to change{ User.count }.by(1)
      end
      it 'creates a session with the new user' do
        session[:user_id].should be_nil
        post :create, provider: omniauth_provider
        session[:user_id].should eq User.last.id
      end
      it 'redirects to the edit profile page with the new user' do
        post :create, provider: omniauth_provider
        response.should redirect_to user_path(User.last.id, edit: 1)
      end
    end
    context 'when the user does exist' do
      before do
        @user = create(:user, uid: omniauth_uid, provider: omniauth_provider)
      end
      it 'does not create a user' do
        expect do
          post :create, provider: omniauth_provider
        end.to change{ User.count }.by(0)
      end
      it 'creates a session with the existing user' do
        session[:user_id].should be_nil
        post :create, provider: omniauth_provider
        session[:user_id].should eq @user.id
      end
      it 'redirects the user to the root url' do
        post :create, provider: omniauth_provider
        response.should redirect_to root_url
      end
    end
  end

  describe 'GET failure' do
    let(:error_msg) { :invalid_credentials }
    it 'redirects to root with authentication failure message' do
      get :failure, { :message => 'failuremsg123' }
      response.should redirect_to root_url
    end
  end
  describe 'DELETE destroy' do
    before { session[:user_id] = 'loggedin12345' }
    it 'clears the session' do
      delete :destroy
      session[:user_id].should be_nil
    end
    it 'redirects to the home page' do
      delete :destroy
      response.should redirect_to root_url
    end
  end
end

