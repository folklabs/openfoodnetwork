orderManagementModule = angular.module("ofn.bulk_order_management", ["ofn.shared_services"])

orderManagementModule.config [
  "$httpProvider"
  (provider) ->
    provider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content")
]

orderManagementModule.controller "AdminOrderMgmtCtrl", [
  "$scope", "$http", "dataFetcher"
  ($scope, $http, dataFetcher) ->
    $scope.updateStatusMessage =
      text: ""
      style: {}

    $scope.lineItems = []

    $scope.initialise = (spree_api_key) ->
      authorise_api_reponse = ""
      dataFetcher("/api/users/authorise_api?token=" + spree_api_key).then (data) ->
        authorise_api_reponse = data
        $scope.spree_api_key_ok = data.hasOwnProperty("success") and data["success"] == "Use of API Authorised"
        if $scope.spree_api_key_ok
          $http.defaults.headers.common["X-Spree-Token"] = spree_api_key
          dataFetcher("/api/enterprises/managed?template=bulk_index&q[is_primary_producer_eq]=true").then (data) ->
            $scope.suppliers = data
            dataFetcher("/api/enterprises/managed?template=bulk_index&q[is_distributor_eq]=true").then (data) ->
              $scope.distributors = data
              $scope.fetchOrders()
        else if authorise_api_reponse.hasOwnProperty("error")
          $scope.api_error_msg = authorise_api_reponse("error")
        else
          api_error_msg = "You don't have an API key yet. An attempt was made to generate one, but you are currently not authorised, please contact your site administrator for access."

    $scope.fetchOrders = ->
      dataFetcher("/api/orders?template=bulk_index").then (data) ->
        $scope.resetOrders data

    $scope.resetOrders = (data) ->
      $scope.orders = data
      $scope.resetLineItems()
      $scope.matchDistributor order for order in $scope.orders

    $scope.resetLineItems = ->
      $scope.lineItems = $scope.orders.reduce (lineItems,order) ->
        for i,line_item of order.line_items
          $scope.matchSupplier line_item
          line_item.order = order
        lineItems.concat order.line_items
      , []

    $scope.matchSupplier = (line_item) ->
      for i, supplier of $scope.suppliers
        if angular.equals(supplier, line_item.supplier)
          line_item.supplier = supplier
          break

    $scope.matchDistributor = (order) ->
      for i, distributor of $scope.distributors
        if angular.equals(distributor, order.distributor)
          order.distributor = distributor
          break
]

orderManagementModule.filter "selectFilter", ->
  return (lineItems,selectedSupplier,selectedDistributor) ->
    filtered = []
    filtered.push line_item for line_item in lineItems when (selectedSupplier == undefined || line_item.supplier == selectedSupplier) &&
      (selectedDistributor == undefined || line_item.order.distributor == selectedDistributor)
    filtered