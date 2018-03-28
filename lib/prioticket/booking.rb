module PrioTicket

  # Describes a Booking
	# This API is called to get a ticket booked and get a barcode/QR-code in response. 
	# The booking API provides a booking reference in response.
	# There are 5 different booking options:
	# - Booking of ticket without timeslot (ticket_class 1).
	# - Booking of ticket with timeslot (ticket_class 2/ticket_class 3), 
	# 	without reservation_reference.
	# - Booking of ticket with timeslot (ticket_class 2/ticket_class 3), 
	# 	with reservation_reference.
  # 
  class Booking
    
    attr_accessor :identifier
    attr_accessor :distributor_id
    # attr_accessor :booking_type
    attr_accessor :booking_type
    attr_accessor :booking_name
    attr_accessor :booking_email
    attr_accessor :notes
    attr_accessor :contact
    attr_accessor :product_language
    attr_accessor :distributor_reference
    attr_accessor :reservation_reference


    # contact details
  	attr_accessor :phone_number
  	attr_accessor :street
  	attr_accessor :postal_code
  	attr_accessor :city

  	# completed booking attrs
  	attr_accessor :booking_reference
  	attr_accessor :booking_status
  	attr_accessor :booking_details

    def initialize(args)
      return if args.nil?
      args.each do |k,v|
        PrioTicket.parse_json_value(self, k,v)
      end
    end

    # 
    # Sends the reservation request tot the API
    # 
    def save
      request_booking
    end


    def canceled
      booking_status == "Cancelled"
    end
    alias_method :canceled?, :canceled


    def success
    	booking_status == "Confirmed"
    end
    for meth in [:success?, :confirmed, :confirmed?]
	    alias_method meth, :success
	  end


    # Fetches information from ticket_details,
    # to validate the input for this booking.
    # e.g. if ticket_type == 2, from/to date are required.
    # 
    # @return [type] [description]
    def ticket
      begin
        @ticket ||= PrioTicket::TicketDetails.find(distributor_id: distributor_id, ticket_id: booking_type['ticket_id'], identifier: identifier)
      rescue
        false
      end
    end


    # 
    # Cancels a Booking
    # 
    # @return Booking
    def self.cancel(distributor_id: nil, booking_reference: nil, distributor_reference: nil, identifier: nil)
      body = {
        request_type: "cancel_booking",
        data: {
          distributor_id: distributor_id,
          booking_reference: booking_reference,
          distributor_reference: booking_reference  
        }
      }
      result = PrioTicket::API.call(body, identifier)
      booking = PrioTicket::Booking.new(result["data"])
      return booking
    end

    # 
    # Gets the status from a Booking
    # 
    # @return Booking
    def self.get_status(distributor_id: nil, booking_reference: nil, distributor_reference: nil, identifier: nil)
      body = {
        request_type: "booking_status",
        data: {
          distributor_id: distributor_id,
          booking_reference: booking_reference,
          distributor_reference: booking_reference  
        }
      }
      result = PrioTicket::API.call(body, identifier)
      booking = PrioTicket::Booking.new(result["data"])
      return booking
    end

    private

    # 
    # Sends the reservation request to the API endpoint
    # and enriches current object with status and reference.
    # 
    def request_booking
      result = PrioTicket::API.call(request_body, identifier)
      parse_result(result)
    end


    # 
    # Computes the details to send to the API
    # 
    # @return Hash
    def request_body
      for att in [:distributor_id, :booking_type, :booking_name, :booking_email, :contact, :notes, :product_language, :distributor_reference]
        raise PrioTicketError.new("Booking is missing attribute `#{att}` (Hash)") unless send(att)
      end
      body = {
        request_type: "booking",
        data: {
        	distributor_id: distributor_id,
        	booking_type: validated_booking_type_hash,
        	booking_name: booking_name,
        	booking_email: booking_email,
        	contact: PrioTicket.openstruct_to_hash(contact).to_h,
        	notes: notes.to_a,
        	product_language: product_language,
        	distributor_reference: distributor_reference
        }
      }
      
      # add pickuppoint to body, if present
      # body[:data][:pickup_point_id] = pickup_point_id if pickup_point_id
      return body
    end

    # 
    # Calculates and validates the information for 'booking_type'
    # 
    # @return Hash
    def validated_booking_type_hash
      
      # loops through all the booking details and raises error 
      # if from/to date_time are not present.
      if ticket
        if [2,3].include?(ticket.ticket_class)
          unless booking_type.from_date_time && booking_type.to_date_time
            unless booking_type.reservation_reference && booking_type.reservation_reference != ''
              puts booking_type.inspect
              err_msg = "The `booking_type` attribute requires a from_date_time and to_date_time for a ticket of ticket_class #{ticket.ticket_class}."
              raise PrioTicketError.new(err_msg)
            end
          end
        end
      end
      data = {}

      data[:ticket_id]              = booking_type.ticket_id unless booking_type.reservation_reference
      data[:booking_details]        = booking_type.booking_details.map{|bd| PrioTicket.openstruct_to_hash(bd)} unless booking_type.reservation_reference
      data[:reservation_reference]  = booking_type.reservation_reference if booking_type.reservation_reference
      
      if booking_type.from_date_time && booking_type.to_date_time
        data[:from_date_time] = booking_type.from_date_time
        data[:to_date_time]   = booking_type.to_date_time
      end
      return data
    end

    # 
    # Parses the return value from the API
    # 
    def parse_result(result)
      self.booking_status     = result["data"]["booking_status"]
      self.booking_reference	= result["data"]["booking_reference"]
      PrioTicket.parse_json_value(self, :booking_details, result["data"]["booking_details"])
    end


	end
end
