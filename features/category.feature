Feature: Category resource
  Create/Update/Delete category

  @vcr
  Scenario: Create category
    Given Zuppler configured with "zuppler" and "abcd"
    And I have a restaurant "1","demorestaurant"
    And I have a menu "21761"
    When I create category with "pizzas","desc","1","2","true"
    Then I should have category created

  @vcr
  Scenario: Update category
    Given Zuppler configured with "zuppler" and "abcd"
    And I have a menu "21761"
    And I have a category "43069"
    When I update category with "ccc","ddd","true","1","1"
    Then I should get success response

  @vcr
  Scenario: Delete category
    Given Zuppler configured with "zuppler" and "abcd"
    And I have a category "43069"
    When I delete category
    Then I should get success response
