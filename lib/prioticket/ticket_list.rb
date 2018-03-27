module PrioTicket

  # 
  # This API provides all the tickets that are available in the PrioTicket system per distributor.
  # 
  # @author [henkm]
  # 
  class TicketList
    
    attr_accessor :tickets
    attr_accessor :distributor_id
    attr_accessor :identifier

    def initialize(args, distributor_id, identifier)
      @tickets = []
      
      # Add ticket details as array of TicketListItem objects
      for ticket_hash in args["data"]["tickets"]
        ticket = Ticket.new(ticket_hash)
        ticket.distributor_id = distributor_id
        ticket.identifier     = identifier
        @tickets << ticket
      end
    end

    # 
    # Calls the request type 'list' with given
    # 
    # @param distributor_id Integer
    # @return [TicketList]
    def self.find(distributor_id: nil, identifier: '')
      result = PrioTicket::API.call(request_body(distributor_id: distributor_id), identifier, false)
      return_obj = self.new(result, distributor_id, identifier)
      return_obj.distributor_id = distributor_id
      return_obj.identifier     = identifier
      return return_obj
    end

    # 
    # Computes the request body to send to the API endpoint
    # @param distributor_id Integer
    # 
    # @return Hash
    def self.request_body(distributor_id: nil)
      {
        request_type: "list",
        data: {
          distributor_id: distributor_id
        }
      }
    end

  end
end
