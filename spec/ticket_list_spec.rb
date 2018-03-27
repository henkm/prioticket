require "spec_helper"

describe 'TicketList' do
  before(:all) do
    # set correct configuration
    PrioTicket.set_credentials_from_environment
  end

  describe '.find' do

    before(:all) do
      PrioTicket.set_credentials_from_environment
      id = "test-#{Time.now.to_i}"
      @ticket_list = PrioTicket::TicketList.find(distributor_id: DIST_ID, identifier: id)
    end
    
    it 'returns an object' do
      expect(@ticket_list).to be_a PrioTicket::TicketList
    end

    it 'has a tickets attribute of type Array' do
      expect(@ticket_list.tickets).to be_an Array
    end

    it 'has a ticket of type TicketDetails' do
      expect(@ticket_list.tickets.first).to be_an PrioTicket::Ticket
    end

    it 'has a ticket_title' do
      expect(@ticket_list.tickets.first.ticket_title).to be_a String
    end

    context "calling methods that aren't available yet" do

      before(:all) do
        PrioTicket.set_credentials_from_environment
        @ticket = @ticket_list.tickets.first
      end

      it 'returns company_opening_times as Array' do
        expect(@ticket.details.company_opening_times).to be_an Array
      end

      it 'returns the start_from time as a string' do

        expect(@ticket.details.company_opening_times.first.start_from).to match /\d{2}:\d{2}:\d{2}/i # "09:00:00"
      end

      it 'returns an array of tags' do
        expect(@ticket.details.tags).to be_an Array
      end
      
    end

  end
end