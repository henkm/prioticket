module PrioTicket

  # Describes a single result from the [TicketList]
  # 
  # @author [henkm]
  # 
  class Ticket
    
    attr_accessor :identifier
    attr_accessor :distributor_id
    attr_accessor :ticket_id
    attr_accessor :ticket_title
    attr_accessor :venue_name
    attr_accessor :txt_language

    def initialize(args)
      return if args.nil?
      args.each do |k,v|
        PrioTicket.parse_json_value(self, k,v)
      end
    end


    # 
    # Queries the TicketDetail method and retruns
    # a [TicketDetails] object.
    # 
    def details
      PrioTicket::TicketDetails.find(distributor_id: distributor_id, ticket_id: ticket_id, identifier: identifier)
    end

    
  end
end
