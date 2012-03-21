require "test/unit"
require "fire_poll"

class TestFirePollMixin < Test::Unit::TestCase
  include FirePoll
  
  def test_can_be_mixed_in
    assert_nothing_raised do
      poll { true }
    end
  end
end
