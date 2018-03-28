require "spec_helper"

describe 'Booking' do

  before(:all) do
    # set correct configuration
    PrioTicket.set_credentials_from_environment
  end

  context 'blank object'  do
    it "creates an object of type Booking in memory" do
      @booking = PrioTicket::Booking.new(booking_name: "John Doe", identifier: "1234")
      expect(@booking).to be_a PrioTicket::Booking
    end

    it "raises an error when saving" do
      @booking = PrioTicket::Booking.new(booking_name: "John Doe", identifier: "1234")
      expect{@booking.save}.to raise_error PrioTicketError
    end
  end

  context 'Booking of ticket without timeslot (ticket_class 1).' do

    before(:all) do
      PrioTicket.set_credentials_from_environment
      @id = "test-#{Time.now.to_i}"
      @ticket_list    = PrioTicket::TicketList.find(distributor_id: DIST_ID, identifier: @id)
      for ticket in @ticket_list.tickets
        ticket = ticket.details
        if ticket.ticket_class == 1
          @ticket = ticket
          break
        end
      end
    end

    before(:each) do
      @booking = PrioTicket::Booking.new(
        identifier: @id,
        distributor_id: DIST_ID,
        booking_type: {
          ticket_id: @ticket.ticket_id,
          booking_details: [{
            ticket_type: "ADULT",
            count: 2,
            extra_options: []
          }]
        },
        booking_name: "John Doe",
        booking_email: "john@example.com",
        contact: {
          address: {
            street: "Amstel 1",
            postal_code: "1011 PN",
            city: "Amsterdam"
          },
          phonenumber: "0643210123"
        },
        notes: ["This is a test booking"],
        product_language: "en",
        distributor_reference: "ABC123456#{rand(999)}"
      )
    end

    it "has a class of 1" do
      expect(@ticket.ticket_class).to eq 1
    end

    it "returns a booking object" do
      expect(@booking).to be_a PrioTicket::Booking
    end

    it "returns expects booking to NOT be confirmed" do
      expect(@booking).not_to be_confirmed
    end

    it "saves the booking and is now confirmed" do
      @booking.save
      expect(@booking).to be_confirmed
      expect(@booking.booking_details.first.ticket_details.count).to eq 2
    end

    describe ".get_status" do
      it "is confirmed" do
        @booking.save
        @booking_with_status = PrioTicket::Booking.get_status(
          identifier: @booking.identifier,
          distributor_id: DIST_ID, 
          booking_reference: @booking.booking_reference, 
          distributor_reference: @booking.distributor_reference
        )
        expect(@booking_with_status).to be_a PrioTicket::Booking
        expect(@booking_with_status).to be_confirmed
      end
    end


    describe ".cancel" do
      it "is canceled" do
        @booking.save
        @booking_with_status = PrioTicket::Booking.cancel(
          identifier: @booking.identifier,
          distributor_id: DIST_ID, 
          booking_reference: @booking.booking_reference, 
          distributor_reference: @booking.distributor_reference
        )
        expect(@booking_with_status).to be_a PrioTicket::Booking
        expect(@booking_with_status).to be_canceled
      end
    end
  end

  context 'Booking of ticket with timeslot (ticket_class 2).' do
    before(:all) do
      PrioTicket.set_credentials_from_environment
      @id = "test-#{Time.now.to_i}"
      @ticket_list    = PrioTicket::TicketList.find(distributor_id: DIST_ID, identifier: @id)
      for ticket in @ticket_list.tickets
        ticket = ticket.details
        if ticket.ticket_class == 2
          @ticket = ticket
          @availabilities = @ticket.availabilities
          break
        end
      end
    end

    before(:each) do
      @booking = PrioTicket::Booking.new(
        identifier: @id,
        distributor_id: DIST_ID,
        booking_type: {
          ticket_id: @ticket.ticket_id,
          booking_details: [{
            ticket_type: "ADULT",
            count: 2,
            extra_options: []
          }]
        },
        booking_name: "John Doe",
        booking_email: "john@example.com",
        contact: {
          address: {
            street: "Amstel 1",
            postal_code: "1011 PN",
            city: "Amsterdam"
          },
          phonenumber: "0643210123"
        },
        notes: ["This is a test booking"],
        product_language: "en",
        distributor_reference: "ABC123456#{rand(999)}"
      )
    end

    it "has a #ticket object" do
      expect(@booking.ticket).to be_a PrioTicket::TicketDetails
    end

    it "has a class of 2" do
      expect(@ticket.ticket_class).to eq 2
    end

    it "returns a booking object" do
      expect(@booking).to be_a PrioTicket::Booking
    end

    it "returns expects booking to NOT be confirmed" do
      expect(@booking).not_to be_confirmed
    end

    it "raises error that date is required" do
      expect{@booking.save}.to raise_error "The `booking_type` attribute requires a from_date_time and to_date_time for a ticket of ticket_class 2."
    end



    it "saves the booking and is now confirmed" do
      @booking.booking_type.from_date_time = @availabilities.first.from_date_time
      @booking.booking_type.to_date_time = @availabilities.first.to_date_time
      @booking.save
      expect(@booking).to be_confirmed
      expect(@booking.booking_details.first.ticket_details.count).to eq 2
    end

    context 'with reservation' do
      before(:all) do
        for availability in @availabilities
          if availability.vacancies > 0
            @availability = availability
            break
          end
        end
        @reservation = PrioTicket::Reservation.new(
          identifier: @id,
          distributor_id: DIST_ID,
          ticket_id: @ticket.ticket_id,
          from_date_time: @availability.from_date_time,
          to_date_time: @availability.to_date_time,
          booking_details: [{ticket_type: "ADULT", count: 1}],
          distributor_reference: "TEST_RESERVATION"
        )
        @reservation.save
      end

      it "has a succesful reservation " do
        expect(@reservation).to be_reserved
      end

      it "saves a booking with only a reservation_reference" do
        @booking.booking_name = nil
        @booking.booking_type.ticket_id = nil
        @booking.booking_type.booking_details = nil
        @booking.booking_type.reservation_reference = @reservation.reservation_reference
        # puts @booking.inspect
        @booking.save

        expect(@booking).to be_confirmed
      end
    end


  end

end
