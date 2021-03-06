module Zuppler
  module Macros
    def self.included(mod)
      class << mod
        alias_method :original_create, :create

        def create(options = {})
          Zuppler.check
          original_create options
        end
      end
    end
  end

  class Model
    include HTTParty
    attr_writer :restaurant_id
    attr_accessor :disable_blank_filter

    class << self
      def log(url, response, options)
        return if Zuppler.logger.nil?

        Zuppler.logger.info ''
        Zuppler.logger.info " ***** Zuppler Url: #{url}"
        Zuppler.logger.debug " ***** Zuppler Request: #{options}"
        Zuppler.logger.debug " ***** Zuppler Response: #{response.body}"
      end
    end

    def log(url, response, options)
      self.class.log url, response, options
    end

    def persisted?
      !new?
    end

    def new?
      id.blank?
    end

    def self.v5_success?(response)
      response.success?
    end

    def v5_success?(response)
      self.class.v5_success? response
    end

    def self.v4_response_code(response)
      return 0 unless response['status'] && response['status']['code']
      response['status']['code'].to_i
    end

    def v4_response_code(response)
      self.class.v4_response_code response
    end

    def self.v4_success?(response)
      response.success? && response['success'] == true
    end

    def v4_success?(response)
      self.class.v4_success? response
    end

    def self.v3_success?(response)
      response.success? && response['success'] == true
    end

    def v3_success?(response)
      self.class.v3_success? response
    end

    def self.v3_response_code(response)
      response['error']['code'].to_i
    end

    def v3_response_code(response)
      self.class.v3_response_code response
    end

    def handle(response, version = 'v3')
      success = send "#{version}_success?", response

      # errors = response['error'] || response['errors'] || []
      # errors.each do |k, v|
      #   errors.add k, v
      # end unless success

      success
    end

    def self.success?(response)
      response.success? && response['valid'] == true
    end

    def success?(response)
      self.class.success? response
    end

    def self.execute_post(url, body, headers = {})
      options = { body: body, headers: headers }
      response = post url, options
      log url, response, options
      response
    end

    def execute_post(url, body, headers = {})
      self.class.execute_post url, body, headers
    end

    def self.execute_update(url, body, headers = {})
      options = { body: body, headers: headers }
      response = nil

      begin
        Retriable.retriable on: Zuppler::RetryError, base_interval: 1 do
          response = put url, options

          unless v4_success? response
            if v4_response_code(response) >= 500
              raise Zuppler::RetryError, response.message
            end
          end
        end

      rescue Zuppler::RetryError => e
        Zuppler.logger.info "Put Request retry failed for: #{url} with message: #{e.message}" if Zuppler.logger
      end

      log url, response, options
      response
    end

    def execute_update(url, body, headers = {})
      self.class.execute_update url, body, headers
    end

    def self.execute_get(url, body, headers = {})
      options = { body: body, headers: headers }

      response = nil
      begin
        Retriable.retriable on: Zuppler::RetryError, base_interval: 1 do
          response = get url, options
          log url, response, options
          unless v4_success? response
            if v4_response_code(response) == 401
              raise Zuppler::NotAuthorized, 'not authorized'
            elsif v4_response_code(response) >= 500
              raise Zuppler::RetryError, response.message
            end
          end
        end
      rescue Zuppler::RetryError
        Zuppler.logger.debug "Get Request retry failed for: #{url}" if Zuppler.logger
      end

      response
    end

    def execute_get(url, body, headers = {})
      self.class.execute_get url, body, headers
    end

    def self.execute_find(url, headers = {})
      options = { headers: headers }
      response = get url, options
      log url, response, options
      response
    end

    def execute_find(url, headers = {})
      self.class.execute_find url, headers
    end

    def self.request_headers(token)
      { 'Authorization' => " Bearer #{token}" }
    end

    def update_attributes(options)
      options.each do |key, value|
        send "#{key}=", value
      end
    end

    def filter_attributes(attrs, *keys)
      attrs.reject { |k, v| keys.include?(k) || (!disable_blank_filter && v.nil?) }
    end

    def requires!(data, *attributes)
      attributes.each do |attr|
        raise ArgumentError, "'#{attr}' is required" unless data.include? attr
      end
    end

    def publish_to_google(params)
      options = { body: params }
      self.class.post google_publish_url, options
    end

    def google_publish_url
      'http://api.' + Zuppler.api_domain + '/google/publish'
    end
  end
end
