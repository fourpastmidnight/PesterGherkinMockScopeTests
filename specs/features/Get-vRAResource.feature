Feature: Can query for resources from vRA

  As a consumer of the vRA REST API
  I want to be able to retrieve information about resources
  So that I can programmatically manage vRA resources

  Background: An authorized REST API user has authenticated with vRA
    Given an authorized REST API user has authenticated with vRA

  Scenario: Can generate correct URLs with specified query options

    Given the following query options:
      | ManagedOnly | WithExtendedData | WithOperations |
      | $false      | $false           | $false         |
      | $true       | $false           | $false         |
    When Get-vRAResource is invoked with the given parameters
    Then the Url generated for the search query should be:
      | UrlSubstring                                                 |
      | /catalog-service/api/consumer/resourceViews                  |
      | /catalog-service/api/consumer/resourceViews?managedOnly=true |
