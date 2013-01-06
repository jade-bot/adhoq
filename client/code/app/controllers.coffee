m = angular.module 'myApp', []

m.config [
  '$locationProvider',
  ($locationProvider) ->
    $locationProvider.html5Mode true
]
