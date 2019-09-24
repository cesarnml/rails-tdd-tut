require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do
  describe "#create" do
    shared_examples_for "unauthorized_requests" do
      let (:error) do
        {
          "status" => "401",
          "source" => { "pointer" => "/data/attributes/code"},
          "title" => "Authentication code is invalid",
          "detail" => "You must provide valid code in order to exchange for token."
        }
      end

      it "should return 401 status code" do 
        subject
        expect(response).to have_http_status(:unauthorized)
        end
      it "should return proper error body" do
        subject
        expect(json['errors']).to include(error)
      end 
    end

    context "when no code provided" do
      subject { post :create }
      it_behaves_like "unauthorized_requests"
    end

    context "when invalid request" do
      let(:github_error) { double('Sawyer::Resource', error: 'bad_verification_code') }
      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        )
          .and_return(github_error)
      end
      subject { post :create, params: { code: "invalid_code" } }
      it_behaves_like "unauthorized_requests"
    end

    context "when success request" do
      let(:user_data) do
        {
          login: 'user1',
          url: 'http://example.com/1',
          avatar_url: 'http://example.com/avatar/1',
          name: 'My Name 1'
        }
      end
      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        )
          .and_return('validaccesstoken')
        allow_any_instance_of(Octokit::Client).to receive(:user).and_return(
          user_data
        )
      end
      subject { post :create, params: { code: "valid_code" } }

      it "should return 201 status code" do
        subject
        expect(response).to have_http_status(:created)
      end

      it "should return proper json" do
        expect { subject }.to change{ User.count }.by(1)
        user = User.find_by(login: 'user1')
        expect(json_data['attributes']).to eq({"token"=> user.access_token.token})
      end
    end
  end
end
