# PrioTicket
[![Gem Version](https://badge.fury.io/rb/prioticket.svg)](https://badge.fury.io/rb/prioticket)
[![Dependency Status](https://gemnasium.com/henkm/prioticket.svg)](https://gemnasium.com/henkm/prioticket)
[![Code Climate](https://codeclimate.com/github/henkm/prioticket/badges/gpa.svg)](https://codeclimate.com/github/henkm/prioticket)

This gem works as a simple Ruby wrapper for the PrioTicket API. All the API functions are implemented.

Instead of working with JSON, you work with Ruby Classes and intuitive methods.

**This gem communicates with the API Version 2.4.** 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'prioticket'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prioticket

## Configuration

First, obtain an API key from PrioTicket. Set it up like this:
```ruby
PrioTicket::Config.api_key      = "MY-API-KEY"
PrioTicket::Config.environment  = "test"
```

To use this gem in a Rails project:
```ruby
# config/development.rb
config.prioticcket.api_key      = "MY-API-KEY"
config.prioticcket.environment  = "test"
```

## Usage
The available classes and methods are listed below. General rule of thumb: all the naming is 100% consistant with the official API Documentation. So use `PrioTicket::Booking.new(booking_name: 'John Doe', booking_email: 'john@example.net')` instead of using the more intuitive `PrioTicket::Booking.new(name: 'John Doe', email: 'john@example.com')`

**Important**: the `Reservation` and `Booking` classes will only create a new reservation/booking in memory, when initialized (e.g. `Reservation.new(...)`). To submit it to the server, call `save`.

### TicketList
To list the available tickets, call:
```ruby
@ticket_list = PrioTicket::TicketList.find(distributor_id: 1234, identifier: "my-unique-order-abc-123")
# Returns an object with a method `tickets`, which returns an array of tickets:
# => <PrioTicket::TicketList @tickets=[##<PrioTicket::Ticket @ticket_id=362, @ticket_title="100 Highlights  Cruise", @venue_name="Stromma Nederland", @txt_language="zh,ru,pt,nl,it,fr,de,es,en">, etc...]>
```

### TicketDetails
There are two ways to collect detailed information about a Ticket from the TicketList:

#### Find them using the `find` method

```ruby
@ticket_details = PrioTicket::TicketDetails.find(distributor_id: 1234, ticket_id: 123, identifier: "my-unique-order-abc-123")
# => <PrioTicket::TicketDetails @ticket_id=1234, @ticket_title="100 Highlights  Cruise", @short_description="The No.1 Amsterdam canal cruise", etc...> 
```

#### Collect them via the parent object
```ruby
@ticket_list = PrioTicket::TicketList.find(distributor_id: 1234, identifier: "my-unique-order-abc-123")
@ticket_details = @ticket_list.first.ticket_details
# => <PrioTicket::TicketDetails @ticket_id=1234, @ticket_title="100 Highlights  Cruise", @short_description="The No.1 Amsterdam canal cruise", etc...> 
```

So to get the tags from a certain TicketDetails, you can call:
```ruby
@ticket_list.first.ticket_details.tags
# => ["Students", "Wheelchair accessible"]
```
or:
```ruby
@ticket_list.first.ticket_details.company_opening_times.first.start_from
# => "09:00:00"

```

### Availabilities
The same goes for fetching availabilities:
```ruby
  @availabilities = PrioTicket::Availabilities.find(distributor_id: 1234, ticket_id: 123, identifier: "my-unique-order-abc-123", from_date: Time.now, until_date: Time.now+(60*60*24*7))
  # or:
  @availabilities = @ticket_details.availabilities(from_date: Time.now, until_date: Time.now+(60*60*24*7))
```

### Reservation
To reserve a date, use the `PrioTicket::Reservation` class:
```ruby
@reservation = PrioTicket::Reservation.new(
  identifier: "my-unique-order-abc-123",
  distributor_id: 1234,
  ticket_id: 123,
  from_date_time: @availabilities.first.from_date_time,
  to_date_time: @availabilities.first.to_date_time,
  booking_details: [{ticket_type: "ADULT", count: 1}],
  distributor_reference: "TEST_RESERVATION"
)
# at this point, the reservation is only made in memory, but not yet
# send to the PrioTicket server. To make in final, call `save`.

@reservation.save
# => #<PrioTicket::Reservation @identifier="test-1522067114", @distributor_id=1234, @ticket_id=123, @from_date_time="2018-03-26T23:00:00+02:00", @to_date_time="2018-03-26T23:59:00+02:00", @booking_details=[#<OpenStruct ticket_type="ADULT", count=1>], @distributor_reference="TEST_RESERVATION", @booking_status="Reserved", @reservation_reference="YYY2067115376XXX">

# Cancel this reservation:
@reservation.cancel
@reservation.booking_status #=> "Cancelled"
```

A direct way to cancel a reservation, is to call the class method `.cancel`:
```ruby
PrioTicket::Reservation.cancel(
  distributor_id: 1234, 
  reservation_reference: "YYY2067115376XXX",
  distributor_reference: "TEST_RESERVATION", 
  identifier: "my-unique-order-abc-123"
)
```

### Booking
To make a booking, please take note of the official API Documentation: for tickets of type_2 and type_3, a `from_date_time` and `to_date_time` must be present. 

Example code in section below.

## Full example
All the steps are combined in the example below:
1. Setup the API credentials
2. Get a list of all the tickets/products
3. Find out details of a specific ticket
4. Get availability
5. Make a booking
6. Get status / cancel booking

```ruby

# step 1
# config/development.rb (in case of Ruby on Rails App)
config.prioticcket.api_key      = "MY-API-KEY"
config.prioticcket.environment  = "test"

# Code below goes in a controller or model, handling the application logic

# step 2
@ticket_list = PrioTicket::TicketList.find(distributor_id: 1234, identifier: "test-123")

# step 3
@ticket = @ticket_list.tickets.first.details
#=> <PrioTicket::TicketDetails> includes name, prices, etc.

# step 4
# method defaults to 3 weeks ahead, you can provice from_date_time and to_date_time
@available_times = @ticket.availabilities

# step 5 - book first available time
@booking = PrioTicket::Booking.new(
  identifier: "test-123",
  distributor_id: 1234,
  booking_type: {
    ticket_id: @ticket.ticket_id,
    booking_details: [{
      ticket_type: "ADULT",
      count: 2,
      extra_options: []
    }]
  },
  booking_name: "John Doe",
  booking_email: "john@example.com",
  contact: {
    address: {
      street: "Amstel 1",
      postal_code: "1011 PN",
      city: "Amsterdam"
    },
    phonenumber: "0643210123"
  },
  notes: ["This is a test booking"],
  product_language: "en",
  distributor_reference: "ABC123456"
)

# the booking is now made in memory, but not yet final
@booking.confirmed?
# => false

@booking.save
# => <PrioTicket::Booking> object, with status and barcodes

@booking.confirmed?
# => true

@booking.cancel
@booking.confirmed?
# => false
@booking.canceled?
# => true

@booking.booking_reference # => 123ABC456XYZ

# another way to ask for the status of a booking:
@booking = PrioTicket::Booking.get_status(
  identifier: @booking.identifier,
  distributor_id: DIST_ID, 
  booking_reference: "123ABC456XYZ", 
  distributor_reference: "ABC123456
)
@booking.status # => "Cancelled"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/henkm/prioticket.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT). No rights can be derrived from using this library.

This gem is made with love by the smart people at [Eskes Media B.V.](https://www.eskesmedia.nl) and [DagjeWeg.NL Tickets](https://www.dagjewegtickets.nl)
PrioTicket is not involved with this project and has no affiliation with Eskes Media B.V.
