# frozen_string_literal: true
RSpec.describe '/recoveries' do
  include Pragma::Devise::Engine.routes.url_helpers

  describe 'POST /' do
    subject { -> { post recoveries_path, params: body.to_json } }

    context 'when the email is valid' do
      let(:user) { create(:user) }

      let(:body) do
        {
          email: user.email
        }
      end

      it 'responds with 204 No Content' do
        subject.call
        expect(last_response.status).to eq(204)
      end
    end

    context 'when the email is invalid' do
      let(:body) do
        {
          email: 'jdoe@example.com'
        }
      end

      it 'responds with 204 No Content' do
        subject.call
        expect(last_response.status).to eq(204)
      end
    end

    context 'when no email is provided' do
      let(:body) { {} }

      it 'responds with 422 Unprocessable Entity' do
        subject.call
        expect(last_response.status).to eq(422)
      end
    end
  end

  describe 'POST /:id/complete' do
    subject { -> { post complete_recovery_path(id: recovery_token), params: body.to_json } }

    context 'when the recovery token is valid and a password is provided' do
      let(:user) { create(:user) }

      let(:recovery_token) { user.send_reset_password_instructions }
      let(:body) do
        {
          password: 'my_new_password'
        }
      end

      it 'responds with 204 No Content' do
        subject.call
        expect(last_response.status).to eq(204)
      end
    end

    context 'when the recovery token is invalid' do
      let(:recovery_token) { 'invalid' }
      let(:body) do
        {
          password: 'my_new_password'
        }
      end

      it 'responds with 422 Unprocessable Entity' do
        subject.call
        expect(last_response.status).to eq(422)
      end
    end

    context 'when no password is provided' do
      let(:user) { create(:user) }

      let(:recovery_token) { user.send_reset_password_instructions }
      let(:body) do
        {
          password: ''
        }
      end

      it 'responds with 422 Unprocessable Entity' do
        subject.call
        expect(last_response.status).to eq(422)
      end
    end
  end
end
