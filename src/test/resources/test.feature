Feature: Restful Booker API - Create Booking

  Background:
    * url 'https://restful-booker.herokuapp.com'

  Scenario: Create a booking with valid data
    Given path 'booking'
    And request
     """
      {
        "firstname" : "Jim",
        "lastname" : "Brown",
        "totalprice" : 111,
        "depositpaid" : true,
        "bookingdates" : {
            "checkin" : "2018-01-01",
            "checkout" : "2019-01-01"
        },
        "additionalneeds" : "Breakfast"
      }
      """
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    When method post
    Then status 200
    And match response.booking.firstname == 'Jim'
    And match response.booking.lastname == 'Brown'
    And match response.booking.totalprice == 111
    And match response.booking.depositpaid == true
    And match response.booking.bookingdates.checkin == '2018-01-01'
    And match response.booking.bookingdates.checkout == '2019-01-01'
    And match response.booking.additionalneeds == 'Breakfast'

  Scenario: Create a booking with invalid data
    Given path 'booking'
    And request
     """
      {
        "lastname" : "Brown",
        "totalprice" : 111,
        "depositpaid" : true,
        "bookingdates" : {
            "checkin" : "2018-01-01",
            "checkout" : "2019-01-01"
        },
        "additionalneeds" : "Breakfast"
      }
      """
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    When method post
    Then status 500

  Scenario: Create and Verify Booking with get from all list
    # Creación del Booking
    Given path 'booking'
    And request
     """
      {
        "firstname" : "Jim",
        "lastname" : "Brown",
        "totalprice" : 111,
        "depositpaid" : true,
        "bookingdates" : {
            "checkin" : "2018-01-01",
            "checkout" : "2019-01-01"
        },
        "additionalneeds" : "Breakfast"
      }
      """
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    When method post
    Then status 200
    * def bookingId = response.bookingid
    * print 'Booking ID:', bookingId

    # Verificación del Booking
    Given path 'booking'
    When method get
    Then status 200
    * def bookingList = response
    * def found = karate.filter(bookingList, function(x){ return x.bookingid == bookingId })
    * assert found.length > 0

  Scenario: Create and Verify Booking with get
    # Creación del Booking
    Given path 'booking'
    And request
     """
      {
        "firstname" : "Juan",
        "lastname" : "Corral",
        "totalprice" : 111,
        "depositpaid" : true,
        "bookingdates" : {
            "checkin" : "2018-01-01",
            "checkout" : "2019-01-01"
        },
        "additionalneeds" : "Launch"
      }
      """
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    When method post
    Then status 200
    * def bookingId = response.bookingid

    # Verificación del Booking
    Given path 'booking' , bookingId
    And header Accept = '*/*'
    And header Accept-encoding = 'gzip, deflate, br'
    When method get
    Then status 200
    And match response.firstname == 'Juan'
    And match response.lastname == 'Corral'
    And match response.totalprice == 111
    And match response.depositpaid == true
    And match response.bookingdates.checkin == '2018-01-01'
    And match response.bookingdates.checkout == '2019-01-01'
    And match response.additionalneeds == 'Launch'


  Scenario: Update booking information with previous authentication
    Given path 'auth'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request
     """
     {
        "username" : "admin",
        "password" : "password123"
     }
     """
    When method post
    Then status 200
    * def token = response.token
    Given path 'booking' , 1
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header Cookie = 'token=' + token
    And request
     """
     {
       "firstname": "Sebastian",
       "lastname": "Betancur",
       "totalprice": 111,
       "depositpaid": true,
       "bookingdates": {
           "checkin": "2018-01-01",
           "checkout": "2019-01-01"
       },
       "additionalneeds": "Breakfast"
     }
     """
    When method put
    Then status 200
    And match response.firstname == 'Sebastian'
    And match response.lastname == 'Betancur'
    And match response.totalprice == 111
    And match response.depositpaid == true
    And match response.bookingdates.checkin == '2018-01-01'
    And match response.bookingdates.checkout == '2019-01-01'
    And match response.additionalneeds == 'Breakfast'