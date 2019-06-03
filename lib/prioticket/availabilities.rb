module PrioTicket

  # This endpoint should be called in order to get up-to-date availability 
  # information for a product with managed capacity. The response will contain
  # the availability for each time slot of the requested product that lies within
  # the specified date range. Time slots will not be omitted in case of no availability. 
  # Neither will a NO_AVAILABILITY error be returned in that case. 
  # Instead, an explicit vacancy of zero should be expected.
  # 
  class Availabilities
    attr_accessor :from_date_time
    attr_accessor :to_date_time
    attr_accessor :vacancies


    def initialize(args=nil)
      return if args.nil?
      args.each do |k,v|
        PrioTicket.parse_json_value(self, k,v)
      end
    end

    # 
    # Calls the request type 'availabilities' with given
    # details and retruns an array of Availabilities objects
    # 
    # @param distributor_id Integer
    # @return Array
    def self.find(distributor_id: nil, ticket_id: nil, from_date: nil, until_date: nil, identifier: nil)
      result = PrioTicket::API.call(request_body(ticket_id: ticket_id, distributor_id: distributor_id, from_date: from_date, to_date: until_date), identifier, false)
      list = []
      if PrioTicket::Config.verbose
        puts "Availablilities:\n#{result['data']}"
      end
      for a in result["data"]["availabilities"]
        list << Availabilities.new(a)
      end
      return list
    end

    # 
    # Computes the request body to send to the API endpoint
    # @param distributor_id Integer
    # @param ticket_id Integer
    # @param from_date String
    # @param until_date String
    # 
    # @return Hash
    def self.request_body(distributor_id: nil, ticket_id: nil, from_date: nil, to_date: nil)
      {
        request_type: "availabilities",
        data: {
          distributor_id: distributor_id,
          ticket_id: ticket_id,
          from_date: PrioTicket.parsed_date(from_date),
          to_date: PrioTicket.parsed_date(to_date)
        }
      }
    end


    def reserve
      # {
      # "request_type": "reserve",
      # "data": {
      # "distributor_id": "501",
      # "ticket_id": "509",
      # "pickup_point_id": "Wyndham_Apollo_hotel",
      # "from_date_time": "2017-11-22T09:00:00+01:00",
      # "to_date_time": "2017-11-23T09:00:00+01:00",
      # "booking_details": [
      # {
      # "ticket_type": "ADULT",
      # "count": 1
      # }
      # ],
      # "distributor_reference": "ABC123456"
      # }
      # }

      # {
      # "response_type": "reserve",
      # "data": {
      # "reservation_reference": "123456789",
      # "distributor_reference": "ABC123456",
      # "booking_status": "Reserved"
      # }
      # }
    end

  end
end
