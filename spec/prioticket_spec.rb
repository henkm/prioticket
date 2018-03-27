require "spec_helper"


describe PrioTicket::Config do
  it "has a version number" do
    expect(PrioTicket::VERSION).not_to be nil
  end

  it "initializes with API key and secret" do
    PrioTicket::Config.api_key = "abc123"
  end

  describe '.request_authentication_key' do
    it 'generates an authentication token' do
      token = PrioTicket::API.request_authentication_key('abc')
      expect(token).to be_a String
      expect(token).to eq 'MwPJqRy27WN703FVKObolkoAf5UbkgY7C9NCd2GT9eM='
    end
  end

end

describe 'API' do

  before(:all) do
    # set correct configuration
    PrioTicket.set_credentials_from_environment
  end

  it "returns test endpoint by default" do
    expect(PrioTicket::API.endpoint).to eq "https://test-api.prioticket.com/v2.4/booking_service"
  end

  it "returns production endpoint in produciton" do
    PrioTicket::Config.environment = "production"
    expect(PrioTicket::API.endpoint).to eq "https://api.prioticket.com/v2.4/booking_service"
    PrioTicket.set_credentials_from_environment # reset to default
  end

  
  describe '.request_header' do
    it 'returns a hash' do
      expect(PrioTicket::API.request_header).to be_a Hash
    end
  end

end
