# Descriccion de la prueba

Automatizar las pruebas de la siguiente API: [https://restfulbooker.herokuapp.com/apidoc/index.html](https://restfulbooker.herokuapp.com/apidoc/index.html)
Condiciones:
- Usar para la automatización de pruebas KarateDSL.
- Incluir pruebas para las operaciones de Create, Update* y Get. Escenarios happy path y alternos.
- tener en cuenta el header ‘Cookie’.

## Escenarios probados

Escenario 1: Se creó una reserva con información válida y se verificó la respuesta de la petición
```gherkin
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
```
Escenario 2: Se creó una reserva con información faltante y se verificó la respuesta 500 de la petición
```gherkin
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
```
Escenario 3: Se creó una reserva con información válida y se verificó que se hubiera almacenado correctamente en línea, comprobando el endpoint [https://restful-booker.herokuapp.com/booking](https://restful-booker.herokuapp.com/booking)
```gherkin
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
```
Escenario 4: Se creó una reserva con información válida y se verificó que se hubiera almacenado correctamente en línea, comprobando la misma reserva en el endpoint. [https://restful-booker.herokuapp.com/booking/idReserva](https://restful-booker.herokuapp.com/booking/idReserva)
```gherkin
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
```
Escenario 5: Se generó un token de autenticación válido y luego se modificó una reserva usando este token, verificando posteriormente la información modificada.
```gherkin
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
```
Escenario 6: Se intentó generar un token con credenciales erróneas y se verificó que no se generara.
```gherkin
Scenario: Verify error with bad credentials
    Given path 'auth'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request
     """
     {
        "username" : "admin",
        "password" : ""
     }
     """
    When method post
    Then status 200
    And match response.reason == 'Bad credentials'
```
