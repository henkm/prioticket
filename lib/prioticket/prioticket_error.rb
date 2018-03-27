class PrioTicketError < StandardError
  attr_accessor :error_message
  attr_accessor :error_code
  
  # def initialize
  #   # @error_message = error_message
  #   # @error_code = error_code
  #   # @description = 
  # end

  # def self.error_code_mapping
  #   {    
  #    "NO_AVAILABILITY" => { exception_name: "No Availability Exception", explanation: "The request cannot be fulfilled because there is insufficient availability.", http_status_code: "400 Bad Request"},
  #    "INVALID_PRODUCT" => { exception_name: "Invalid Product Exception", explanation: "The specified product does not exist.", http_status_code: "400 Bad Request"},
  #    "INVALID_RESERVATION" => { exception_name: "Invalid Reservation Exception", explanation: "The specified reservation does not exist or is not in a valid state.", http_status_code: "400 Bad Request"},
  #    "INVALID_BOOKING" => { exception_name: "Invalid Booking Exception", explanation: "The specified booking does not exist or is not in a valid state.", http_status_code: "400 Bad Request"},
  #    "INVALID_REQUEST" => { exception_name: "Invalid Identifier Exception", explanation: "Invalid request contents.", http_status_code: "400 x-request-identif => er header invalid"},
  #    "AUTHORIZATION_FAILURE" => { exception_name: "Invalid Authentication Exception", explanation: "The provided credentials are not valid.", http_status_code: "401 x-request-authenticati => n header invalid."},
  #    "VALIDATION_FAILURE" => { exception_name: "Validation Exception", explanation: "The request object contains inconsistent or invalid data or is missing data.", http_status_code: "400 Bad Request"},
  #    "INVALID_TICKET_CLASS" => { exception_name: "Invalid TicketClass Exception", explanation: "This endpoint can only be requested for ticket_class 2/ticket_class 3 (product of managed capacity).", http_status_code: "400 Bad Request"},
  #    "AUTHORIZATION_FAILURE" => { exception_name: "Authorization Exception", explanation: "The provided credentials are not valid.", http_status_code: "401 Unauthorized"},
  #    "BOOKING_CANCELLED" => { exception_name: "Redeem Booking Cancelled Exception", explanation: "This booking has been cancelled.", http_status_code: "400 Bad Request"},
  #    "INVALID_TICKET_CODE" => { exception_name: "Redeem Ticketcode Invalid Exception", explanation: "Provided ticket code is not valid.", http_status_code: "400 Bad Request"},
  #    "DATE_MISMATCH" => { exception_name: "Redeem Date Mismatch Exception", explanation: "This ticket isn't valid for today.", http_status_code: "400 Bad Request"},
  #    "INTERNAL_SYSTEM_FAILURE" => { exception_name: "InternalSystem Exception", explanation: "An error occurred that is unexpected and/or doesn’t fit any of the types above.", http_status_code: "500 Internal Server Error"}
  #    }
  # end
end