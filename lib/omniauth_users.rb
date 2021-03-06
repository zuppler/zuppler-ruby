module OmniAuth
  module Strategies
    class Users < OmniAuth::Strategies::OAuth2
      option :name, :users
      option :client_options, site: ::Zuppler.users_url

      uid { data['uid'] }

      info do
        {
          id: data['info']['id'],
          name: data['info']['name'],
          email: data['info']['email'],
          phone: data['info']['phone'],
          roles: data['info']['roles']
        }
      end

      extra do
        {
          provider: data['provider']
        }
      end

      def request_phase
        options[:authorize_params][:provider] = request.params['provider']
        options[:authorize_params][:provider_page] = request.params['provider_page']
        options[:authorize_params][:locale] = request.params['locale'] if request.params['locale'].present?
        options[:authorize_params][:theme] = request.params['theme'] if request.params['theme'].present?

        # create account flow
        options[:authorize_params][:back_uri] = request.params['back_uri'] if request.params['back_uri'].present?
        options[:authorize_params][:restaurant_id] = request.params['restaurant_id'] if request.params['restaurant_id'].present?
        options[:authorize_params][:channel_id] = request.params['channel_id'] if request.params['channel_id'].present?

        super
      end

      def data
        @data ||= access_token.get('/users/current.json').parsed
      end
    end
  end
end
