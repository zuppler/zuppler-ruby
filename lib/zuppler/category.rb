module Zuppler
  class Category < Model
    include ActiveAttr::Model

    attribute :menu
    attribute :id
    attribute :name
    attribute :description
    attribute :priority
    attribute :active
    attribute :priced_by_size

    validates_presence_of :menu, :name
    validate do
      errors.add :menu, 'id is missing' if menu and menu.id.blank?
    end

    def save
      if new?
        category_attributes = filter_attributes attributes, 'menu'
        response = execute_create categories_url, {category: category_attributes}
        self.id = response['category']['id'] if v3_success? response
      else
        category_attributes = filter_attributes attributes, 'menu', 'id'
        response = execute_update category_url, {category: category_attributes}
      end
      v3_success? response
    end

    def destroy
      self.active = false
      save
    end

    def restaurant
      menu.restaurant
    end

    protected

    def category_url
      "#{Zuppler.api_url('v3')}/restaurants/#{restaurant.permalink}/categories/#{id}.json"
    end

    def categories_url
      "#{Zuppler.api_url('v3')}/restaurants/#{restaurant.permalink}/menus/#{menu.id}/categories.json"
    end
  end
end
