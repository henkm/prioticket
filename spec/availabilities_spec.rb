require "spec_helper"

describe 'Availabilities' do
  describe '.find' do
    before(:all) do
      PrioTicket.set_credentials_from_environment
      @id = "test-#{Time.now.to_i}-#{rand(999)}"
      @ticket_list    = PrioTicket::TicketList.find(distributor_id: DIST_ID, identifier: @id)
      @availabilities = PrioTicket::Availabilities.find(distributor_id: DIST_ID, ticket_id: @ticket_list.tickets.first.ticket_id, identifier: @id, from_date: Time.now, until_date: Time.now+(60*60*24*7))
    end


    it 'returns an Array' do
      expect(@availabilities).to be_an Array
    end

    it "has instances of PrioTicket::Availabilities" do
      expect(@availabilities.first).to be_an PrioTicket::Availabilities
    end

    it 'has a from_date_time attribute of type DateTime' do
      expect(@availabilities.first.from_date_time).to be_a DateTime
    end


  end
end

