require 'aruba/rspec'
require 'pry'
require 'timecop'

require 'support/logger'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'  # Use --seed NNNN to run in particular order

  config.include ArubaDoubles

  config.before :each do
    Aruba::RSpec.setup
  end

  config.after :each do
    Aruba::RSpec.teardown
    Timecop.return
  end
end
