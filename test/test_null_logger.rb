require 'test_helper'

require 'null_logger'

class TestNullLogger < MiniTest::Unit::TestCase
  def test_logger_can_add
    logger = NullLogger.new(1, 2, 3, 4)
    assert logger.respond_to?(:add)
  end
end
