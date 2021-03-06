Feature: Item resource
  Create/Update/Delete item

  @vcr
  Scenario: Create item
    Given Zuppler configured with "zuppler" and "abcd"
    And I have a restaurant "1","demorestaurant"
    And I have a menu "235"
    And I have a category "1712"
    When I create item with "magio","desc","9.99","1","small","2","5"
    Then I should have item created

  @vcr
  Scenario: Update item
    Given Zuppler configured with "zuppler" and "abcd"
    And I have a category "1712"
    And I have an item "448591"
    When I update item with "diavolo","dddd","8.99","2","5"
    Then I should get success response

  @vcr
  Scenario: Delete item
    Given Zuppler configured with "zuppler" and "abcd"
    And I have an item "448591"
    When I delete item
    Then I should get success response
    
