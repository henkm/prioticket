require "spec_helper"

context 'TicketDetails' do
  before(:all) do
    # set correct configuration
    PrioTicket.set_credentials_from_environment
  end

  describe '.find' do
    before(:all) do
      PrioTicket.set_credentials_from_environment
      @id = "test-#{Time.now.to_i}"
      @ticket_list    = PrioTicket::TicketList.find(distributor_id: DIST_ID, identifier: @id)
    end

    context 'correct information' do
      before(:all) do
        PrioTicket.set_credentials_from_environment
        @ticket_details = PrioTicket::TicketDetails.find(distributor_id: DIST_ID, ticket_id: @ticket_list.tickets.first.ticket_id, identifier: @id)

      end
      
      it 'returns an object' do
        expect(@ticket_details).to be_a PrioTicket::TicketDetails
      end

      it 'has a short description' do
        expect(@ticket_details.short_description).to be_a String
        expect(@ticket_details.short_description.length).to be > 1
      end

      it 'has a short description' do
        expect(@ticket_details.short_description).to be_a String
        expect(@ticket_details.short_description.length).to be > 1
      end

      describe "#availabilities" do
        before(:all) do
          @availabilities = @ticket_details.availabilities(from_date: Time.now, until_date: Time.now+(60*60*24*7))
        end

        it 'has an Array of availabilities' do
          expect(@availabilities).to be_an Array
        end
      end

    end

    context 'incorrect information' do
      before(:all) do
        PrioTicket.set_credentials_from_environment
      end

      it 'returns an object' do
        expect{PrioTicket::TicketDetails.find(distributor_id: DIST_ID, ticket_id: 123, identifier: @id)}.to raise_error(PrioTicketError)
      end
    end
  end
end