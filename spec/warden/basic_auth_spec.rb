require 'spec_helper'
require 'warden/manager'
require 'warden/basic_auth'

describe Warden::BasicAuth do
  it 'has a version number' do
    expect(Warden::BasicAuth::VERSION).not_to be nil
  end

  describe 'GET /test' do
    let(:test_app) do
      ->(env) { [200, env, "secret site"] }
    end

    context 'without basic auth' do
      let(:app) { test_app }
      let(:response) { call_app '/test' }

      it "renders 'secret site'" do
        expect(response.body.first).to eq 'secret site'
      end

      it 'returns HTTP 200' do
        expect(response.status).to eq 200
      end
    end

    context 'with basic auth' do
      before do
        class TestBasicAuth < Warden::Strategies::BasicAuth
          def authenticate_user(username, password)
            username == 'admin' && password == 'adminadmin'
          end
        end

        Warden::Strategies.add :basic_auth, TestBasicAuth
      end

      let(:protected_app) do
        lambda do |env|
          env['warden'].authenticate!

          test_app.call env
        end
      end

      let(:warden) do
        Warden::Manager.new protected_app, default_strategies: [:basic_auth],
                                           failure_app: ->(env) { [403, {}, 'y u no authenticate'] }
      end

      let(:app) { warden }

      context 'without credentials' do
        let(:response) { call_app '/test' }

        it "renders 'y u no authenticate'" do
          expect(response.body.first).to eq 'y u no authenticate'
        end

        it 'returns HTTP 403' do
          expect(response.status).to eq 403
        end
      end

      context 'with incorrect credentials' do
        let(:response) { call_app '/test', basic_auth('hans', 'sesameopen') }

        it "renders 'unauthorized'" do
          expect(response.body.first).to eq 'unauthorized'
        end

        it 'returns HTTP 401' do
          expect(response.status).to eq 401
        end

        it "returns the 'WWW-Authenticate' header" do
          expect(response['WWW-Authenticate']).to include 'Basic realm='
        end
      end

      context 'with correct credentials' do
        let(:response) { call_app '/test', basic_auth('admin', 'adminadmin') }

        it "renders 'secret site'" do
          expect(response.body.first).to eq 'secret site'
        end

        it 'returns HTTP 200' do
          expect(response.status).to eq 200
        end
      end
    end
  end
end
