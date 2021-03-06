module Zuppler
  class Discount < Model
    include ActiveAttr::Model, HTTParty

    attribute :restaurant

    attribute :id
    attribute :loyalty_id
    attribute :order_uuid
    attribute :name
    attribute :amount
    attribute :percent
    attribute :min_order_amount
    attribute :promo_code

    def self.find(id, restaurant_id, order_uuid, loyalty_id = nil)
      new id: id, restaurant_id: restaurant_id, order_uuid: order_uuid, loyalty_id: loyalty_id
    end

    def save
      if new?
        discount_attributes = filter_attributes attributes, 'restaurant'
        response = execute_post discounts_url, discount: discount_attributes
        self.id = resource_id(response) if v4_success?(response)
      else
        discount_attributes = filter_attributes attributes, 'restaurant', 'id'
        response = execute_update discount_url, discount: discount_attributes
      end
      v4_success? response
    end

    def commit(payload)
      response = execute_post commit_discount_url, payload.to_json, headers
      v5_success? response
    end

    def checkin_order(payload)
      response = execute_post checkin_order_url, payload.to_json, headers
      v5_success? response
    end

    def cancel(payload)
      response = execute_post cancel_discount_url, payload.to_json, headers
      v5_success? response
    end

    def cancel_checkin_order(payload)
      response = execute_post cancel_checkin_order_url, payload.to_json, headers
      v5_success? response
    end

    def restaurant_id
      @restaurant_id || restaurant.permalink
    end

    private

    def headers
      {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    def resource_id(response)
      $1 if response.headers['Location'] =~ /\/discounts\/(\d+).json/
    end

    def discount_url
      "#{Zuppler.restaurants_api_url('v4')}/restaurants/#{restaurant_id}/discounts/#{id}.json"
    end

    def discounts_url
      "#{Zuppler.restaurants_api_url('v4')}/restaurants/#{restaurant_id}/discounts.json"
    end

    def commit_discount_url
      "#{Zuppler.loyalties_api_url()}/restaurants/#{restaurant_id}/discounts/#{id}/commit"
    end

    def cancel_discount_url
      "#{Zuppler.loyalties_api_url()}/restaurants/#{restaurant_id}/discounts/#{id}/cancel"
    end

    def checkin_order_url
      "#{Zuppler.loyalties_api_url()}/orders/#{order_uuid}/checkin"
    end

    def cancel_checkin_order_url
      "#{Zuppler.loyalties_api_url()}/orders/#{order_uuid}/cancel_checkin"
    end
  end
end
