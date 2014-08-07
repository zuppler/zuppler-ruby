module Zuppler
  class Choice < Model
    include ActiveAttr::Model
    
    attribute :category
    attribute :item
    attribute :modifier_id
    attribute :id
    attribute :name
    attribute :description
    attribute :active
    attribute :multiple
    attribute :min_qty, default: 0
    attribute :max_qty
    attribute :priority
    attribute :order_by_priority
    
    validates_presence_of :name
    validate do
      errors.add :restaurant, 'permalink is required' if restaurant and restaurant.permalink.blank?
    end

    def self.find(id, restaurant_id)
      new id: id, restaurant_id: restaurant_id
    end

    def save
      if new?
        choice_attributes = filter_attributes attributes, 'category', 'item'
        response = execute_create choices_url, {:choice => choice_attributes}
        self.id = response['choice']['id'] if v3_success?(response)
      else
        choice_attributes = filter_attributes attributes, 'category', 'item', 'id'
        response = execute_update choice_url, {:choice => choice_attributes}
      end
      v3_success? response
    end

    def destroy
      self.active = false
      self.min_qty = nil
      save
    end

    def restaurant
      category ? category.restaurant : item.restaurant
    end
    def restaurant_id
      @restaurant_id || parent_restaurant_id || restaurant.permalink
    end

    protected

    def parent_restaurant_id
      category ? category.restaurant_id : item.restaurant_id
    end

    def choice_url
      "#{Zuppler.api_url('v3')}/restaurants/#{restaurant_id}/choices/#{id}.json"
    end

    def choices_url
      if category
        "#{Zuppler.api_url('v3')}/restaurants/#{restaurant_id}/categories/#{category.id}/choices.json"
      else
        "#{Zuppler.api_url('v3')}/restaurants/#{restaurant_id}/items/#{item.id}/choices.json"
      end
    end
  end
end
