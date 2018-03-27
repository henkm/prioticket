# require dependencies
require 'digest'
require 'rest_client'
require 'json'
require 'base64'
require 'ostruct'
require 'date'

# require gem files
require "prioticket/version"
require "prioticket/prioticket_error"
require "prioticket/config"
require "prioticket/engine" if defined?(Rails) && Rails::VERSION::MAJOR.to_i >= 3

# require API parts
require "prioticket/api"
require "prioticket/ticket_list"
require "prioticket/ticket"
require "prioticket/ticket_details"
require "prioticket/availabilities"
require "prioticket/reservation"
require "prioticket/booking"

module PrioTicket

  # For testing purpose only: set the username and password
  # in environment variables to make the tests pass with your test
  # credentials.
  def self.set_credentials_from_environment
    # puts "Setting API Key: #{ENV["PRIOTICKET_API_KEY"]}"
    Config.api_key = ENV["PRIOTICKET_API_KEY"]
    Config.environment = :test
    Config.verbose = false
  end

  # 
  # Formats time in ISO-8601
  # Expected output: 2016-05-12T14:00:00+04:00
  # Not expected: 2016-05-12T10:00:00+08:00 / 2016-05-12T18:00:00+00:00
  # 
  # @return [type] [description]
  def self.parsed_date(date)
    if date.is_a?(String)
      date
    elsif [DateTime, Time].include?(date.class)
      date.strftime(expected_date_format)
      # date.strftime('%Y-%m-%d')
    end
  end

  # 
  # Formats time in ISO-8601
  # 
  # @return [type] [description]
  def self.expected_date_format
    '%Y-%m-%dT%H:%M:%S%z'
  end

  # Converts OpenStruct back to a hash
  def self.openstruct_to_hash(object, hash = {})
    object.each_pair do |key, value|
      hash[key] = value.is_a?(OpenStruct) ? openstruct_to_hash(value) : value
    end
    hash
  end

  # 
  # Takes a hash and assignes it to the proper attributes.
  # - Integers will be parsed as floats
  # - Floats will be parsed as floats
  # - Boolean values will bu parsed as such
  # - Hash and Array will bet a type of 'OpenStruct'
  # - DateTime will be a type of DateType
  # - All other values will be used as string
  # 
  def self.parse_json_value(obj, k,v)
    unless v.nil?
      # "2018-03-24T00:00:00+01:00"
      is_integer    = !!Integer(v) rescue false
      is_float      = !!Float(v) rescue false
      is_date_time  = !!DateTime.strptime(v, expected_date_format) rescue false
      if ["true", "false"].include?(v)
        val = (v == 'true')
      elsif is_integer
        val = v.to_i
      elsif is_date_time
        val = DateTime.strptime(v, expected_date_format)
      elsif is_float
        val = v.to_f
      elsif [Hash, Array].include?(v.class)
        val = JSON.parse(v.to_json, object_class: OpenStruct)
      else
        val = v
      end
      obj.instance_variable_set("@#{k}", val)
    end
  end

end
