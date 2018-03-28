require "spec_helper"

context 'Reservation', focus: true do
  before(:all) do
    PrioTicket.set_credentials_from_environment
    @id = "test-#{Time.now.to_i}"
    # @ticket_list    = PrioTicket::TicketList.find(distributor_id: DIST_ID, identifier: @id)
    # @ticket = @ticket_list.tickets[5].details
    @ticket = PrioTicket::TicketDetails.find(distributor_id: DIST_ID, ticket_id: 2574, identifier: @id)
    @availabilities = PrioTicket::Availabilities.find(distributor_id: DIST_ID, ticket_id: @ticket.ticket_id, identifier: @id, from_date: Time.now, until_date: Time.now+(60*60*24*7)).first
  end

  before(:each) do
    @reservation = PrioTicket::Reservation.new(
      identifier: @id,
      distributor_id: @ticket.distributor_id,
      ticket_id: @ticket.ticket_id,
      from_date_time: @availabilities.from_date_time,
      to_date_time: @availabilities.to_date_time,
      booking_details: [{ticket_type: "ADULT", count: 1}],
      distributor_reference: "TEST_RESERVATION"
    )
    @reservation.save
  end

  it "has a ticket of class 2 or 3" do
    # This endpoint can only be requested for ticket_class 2/ticket_class 3 (product with managed capacity).
    expect([2,3]).to include(@ticket.ticket_class)
  end

  it "creates a new reservation" do
    expect(@reservation.booking_status).to eq "Reserved"
  end


  it "cancels and has booking_status of Cancelled" do
    @reservation.cancel
    expect(@reservation.booking_status).to eq "Cancelled"
  end

  it 'cancels with .cancel' do
    @new_reservation = PrioTicket::Reservation.cancel(distributor_id: DIST_ID, reservation_reference: @reservation.reservation_reference, distributor_reference: @reservation.distributor_reference, identifier: @id)
    expect(@new_reservation.booking_status).to eq "Cancelled"
    expect(@new_reservation.cancelled).to eq true
  end

end
