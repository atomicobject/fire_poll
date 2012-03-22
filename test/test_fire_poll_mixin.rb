require "test/unit"
require "fire_poll"

class TestFirePollMixin < Test::Unit::TestCase
  include FirePoll
  
  def test_poll_can_be_mixed_in
    assert_nothing_raised do
      poll { true }
    end
  end

  def test_patiently_can_be_mixed_in
    assert_nothing_raised do
      a = patiently { true }
      assert_equal a, true
    end
  end
end
