module PrioTicket

  # 
  # This API provides all the ticket information that is available in 
  # the PrioTicket system for requested `ticket_id`.
  # 
  # @author [henkm]
  # 
  class TicketDetails

    attr_accessor :identifier
    attr_accessor :distributor_id

    # attributes already available from ticketlist
    attr_already_known_from_ticketlist = [:ticket_id, :ticket_title, :venue_name, :txt_language]
    for att in attr_already_known_from_ticketlist
      attr_accessor att
    end

    detailed_attributes = [:short_description, :long_description, :highlights, 
      :duration, :combi_ticket, :ticket_entry_notes, :tags, :included, :company_opening_times,
      :book_size_min, :book_size_max, :supplier_url, :ticket_class, :start_date, :end_date,
      :booking_start_date, :images, :currency, :product_language, :pickup_points, 
      :pickup_point_details, :ticket_type_details]

    for att in detailed_attributes
      attr_accessor att
    end


    def initialize(args=nil)
      return if args.nil?
      args.each do |k,v|
        PrioTicket.parse_json_value(self, k,v)
      end
    end


    # 
    # Calls the request type 'details' with given
    # 
    # @param distributor_id Integer
    # @return TicketDetails
    def self.find(distributor_id: nil, ticket_id: nil, identifier: nil)
      result = PrioTicket::API.call(request_body(ticket_id: ticket_id, distributor_id: distributor_id), identifier)
      new_obj = self.new(result["data"])
      new_obj.distributor_id = distributor_id
      new_obj.identifier = identifier
      return new_obj
    end

    # 
    # Computes the request body to send to the API endpoint
    # @param distributor_id Integer
    # 
    # @return Hash
    def self.request_body(ticket_id: nil, distributor_id: nil)
      {
        request_type: "details",
        data: {
          distributor_id: distributor_id,
          ticket_id: ticket_id
        }
      }
    end


    # 
    # Finds availabilities for given dates
    # 
    # @param from_date: DateTime
    # @param until_date: DateTime
    # 
    # @return [type] [description]
    def availabilities(from_date: Time.now, until_date: Time.now+(60*60*24*21))
      PrioTicket::Availabilities.find(distributor_id: distributor_id, ticket_id: ticket_id, identifier: identifier, from_date: from_date, until_date: until_date)      
    end

    def reserve_timeslot
    # "request_type": "reserve",
    # "data": {
    #   "distributor_id": "501",
    #   "ticket_id": "509",
    #   "pickup_point_id": "Wyndham_Apollo_hotel",
    #   "from_date_time": "2017-11-22T09:00:00+01:00",
    #   "to_date_time": "2017-11-23T09:00:00+01:00",
    #   "booking_details": [
    #     {
    #       "ticket_type": "ADULT",
    #       "count": 1
    #     }
    #   ],
    #   "distributor_reference": "ABC123456"
    end

  end
end
