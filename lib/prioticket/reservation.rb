module PrioTicket

  # Describes a Reservation
  # 
  # @author [henkm]
  # 
  class Reservation

    attr_accessor :identifier
    attr_accessor :distributor_id
    attr_accessor :ticket_id
    attr_accessor :pickup_point_id
    attr_accessor :from_date_time
    attr_accessor :to_date_time
    attr_accessor :booking_details
    attr_accessor :distributor_reference
    
    attr_accessor :reservation_reference
    attr_accessor :booking_status
    attr_accessor :cancellation_date_time

    def initialize(args)
      return if args.nil?
      args.each do |k,v|
        PrioTicket.parse_json_value(self, k,v)
      end
    end

    def success
      booking_status == "Reserved"
    end
    for meth in [:success?, :confirmed, :confirmed?, :reserved, :reserved?]
      alias_method meth, :success
    end


    # 
    # Sends the reservation request tot the API
    # 
    def save
      request_reservation
    end

    # 
    # Cancels the current reservation
    # 
    # @return <Reservation>
    def cancel
      result = PrioTicket::API.call(cancel_request_body, identifier)
      parse_result(result)
    end

    private

    # 
    # Sends the reservation request to the API endpoint
    # and enriches current object with status and reference.
    # 
    def request_reservation
      result = PrioTicket::API.call(request_body, identifier)
      parse_result(result)
    end


    # 
    # Parses the return value from the API
    # `{"response_type"=>"reserve", "data"=>
    # {"reservation_reference"=>"1522065689487477", 
    # "distributor_reference"=>"TEST_RESERVATION", 
    # "booking_status"=>"Reserved"}}`
    # 
    # @return [type] [description]
    def parse_result(result)
      self.booking_status         = result["data"]["booking_status"]
      self.reservation_reference  = result["data"]["reservation_reference"]
      if result["data"]["cancellation_date_time"]
        PrioTicket.parse_json_value(self, :cancellation_date_time, result["data"]["cancellation_date_time"])
      end
    end


    # Computes the request body to send to the API cancel_reserve endpoint
    def cancel_request_body
      { 
        request_type: "cancel_reserve",
        data: {
          distributor_id: distributor_id,
          reservation_reference: reservation_reference,
          distributor_reference: distributor_reference
        }
      }
    end

    # 
    # Computes the request body to send to the API endpoint
    # @param distributor_id Integer
    # @param ticket_id Integer
    # @param from_date String
    # @param until_date String
    # 
    # @return Hash
    def request_body
      booking_details_array = booking_details.to_a.map{|bd| bd.to_h}
      body = {
        request_type: "reserve",
        data: {
          distributor_id: distributor_id.to_s,
          ticket_id: ticket_id.to_s,
          from_date_time: PrioTicket.parsed_date(from_date_time),
          to_date_time: PrioTicket.parsed_date(to_date_time),
          booking_details: booking_details_array,
          distributor_reference: distributor_reference
        }
      }
      
      # add pickuppoint to body, if present
      body[:data][:pickup_point_id] = pickup_point_id if pickup_point_id
      return body
    end
    
  end
end
