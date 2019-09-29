require 'rails_helper'

describe UserAuthenticator::Oauth do
  describe '#perform' do
    let(:authenticator) { described_class.new('sample_code') }

    subject { authenticator.perform }

    context 'when code is incorrect' do
      let(:error) { double('Sawyer::Resource', error: 'bad_verification_code') }
      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        )
          .and_return(error)
      end
      it 'should raise an error' do
        expect { subject }.to raise_error(
          UserAuthenticator::Oauth::AuthenticationError
        )
        expect(authenticator.user).to be_nil
      end
    end

    context 'when code is correct' do
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
      it 'should save the user when does not exists' do
        expect { subject }.to change { User.count }.by(1)
        expect(User.last.name).to eq('My Name 1')
      end

      it 'should reuse already registered user' do
        user = create :user, user_data
        expect { subject }.not_to (change { User.count })
        expect(authenticator.user).to eq(user)
      end
    end
  end
end
