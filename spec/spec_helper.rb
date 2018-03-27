$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "prioticket"

# fetch the Dist ID from ENV variable, so it is not included in this gems repo.
DIST_ID = ENV["PRIOTICKET_DIST_ID"]


RSpec.configure do |c|
  # filter_run is short-form alias for filter_run_including
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end