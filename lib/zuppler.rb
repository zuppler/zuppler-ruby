require 'active_model'
require 'active_attr'
require 'httparty'
require 'multi_json'
require 'hashie'
require 'retriable'

require 'zuppler/version'
require 'zuppler/model'
require 'zuppler/request'

require 'zuppler/channel'
require 'zuppler/restaurant'
require 'zuppler/menu'
require 'zuppler/category'
require 'zuppler/item'
require 'zuppler/choice'
require 'zuppler/ingredient'
require 'zuppler/modifier'
require 'zuppler/option'

require 'zuppler/order'
require 'zuppler/notification'
require 'zuppler/discount'
require 'zuppler/user'
require 'zuppler/application'
require 'zuppler/provider'

module Zuppler
  class Error < StandardError
  end
  class RetryError < Error
  end
  class ServerError < Error
  end
  class SkipCache < Error
  end
  class NotAuthorized < Error
  end

  class << self
    attr_accessor :channel_key, :restaurant_key, :api_key
    attr_accessor :test, :domains, :logger
    attr_writer :cache

    DEFAULT_DOMAINS = {
      production: 'zuppler.com',
      staging: 'biznettechnologies.com',
      development: 'zuppler.test',
      test: 'biznettechnologies.com'
    }.freeze
    DEFAULT_CACHE = {}.freeze

    def init(channel_key, api_key, test = true, logger = nil)
      self.channel_key, self.api_key = channel_key, api_key
      self.test, self.logger = test, logger
      self.cache = DEFAULT_CACHE
    end

    def configure
      yield self
    end
    alias_method :config, :configure

    def check
      raise Zuppler::Error, ':channel_key cannot be blank' if channel_key.blank?
      raise Zuppler::Error, ':api_key cannot be blank' if api_key.blank?
    end

    def api_domain
      api_domains = DEFAULT_DOMAINS.merge(domains || {})
      if defined? Rails
        api_domains[Rails.env.to_sym]
      elsif test?
        api_domains[:test]
      else
        api_domains[:production]
      end
    end

    def cache
      @cache || DEFAULT_CACHE
    end

    def api_version
      '/v2'
    end

    def channels_uri
      "/channels/#{channel_key}"
    end

    def api_url(version = 'v2')
      'http://api.' + api_domain + "/#{version}" + channels_uri
    end

    def restaurants_api_url(version = 'v4')
      'http://restaurants-api.' + api_domain + "/#{version}"
    end

    def orders_api_url(version = 'v4')
      'http://secure.' + DEFAULT_DOMAINS[:development] + "/#{version}" if test? || (defined? Rails && Rails.env.to_sym == :development)
      'http://orders-api.' + api_domain + "/#{version}"
    end

    def users_api_url(version = 'v1')
      'http://users-api.' + api_domain + "/#{version}"
    end

    def loyalties_api_url(version = 'v5')
      'http://loyalty-api.' + api_domain + "/#{version}"
    end

    def users_url
      "#{scheme}://users.#{api_domain}"
    end

    def scheme
      ssl? ? 'https' : 'http'
    end

    def ssl?
      api_domain.include? 'zuppler.com'
    end

    def test?
      !!test
    end

    def channel
      @channel ||= Zuppler::Channel.find channel_key
    end
  end
end

require 'omniauth-oauth2'
require 'omniauth_users'
