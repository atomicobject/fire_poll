require "test/unit"
require "fire_poll"

class FirePollTest < Test::Unit::TestCase
  def test_raises_when_block_does_not_yield_true
    assert_raise RuntimeError do
      FirePoll.poll { false }
    end
  end

  def test_does_not_raise_when_block_yields_true
    assert_nothing_raised do
      FirePoll.poll { true }
    end
  end

  def test_does_not_raise_when_block_eventually_yields_true
    assert_nothing_raised do
      count = 0
      FirePoll.poll do
        count += 1
        count > 5 ? true : false
      end
    end
  end

  def test_can_take_an_optional_number_of_seconds_to_poll
    # default 2 seconds = 20 calls to the block
    assert_nothing_raised do
      count1 = 0
      FirePoll.poll do
        count1 += 1
        count1 > 11 ? true : false
      end
    end

    # 1 second = 10 calls to the block
    assert_raise RuntimeError do
      count = 0
      FirePoll.poll(nil, 1) do
        count += 1
        count > 11 ? true : false
      end
    end
  end

  def test_can_take_an_optional_message
    # anyone know a better way to do this with straight-up Test::Unit?
    begin
      FirePoll.poll("custom message") { false }
    rescue RuntimeError => ex
      assert_equal "custom message", ex.message
      return
    end
    flunk "should have raised"
  end
end

class TestFirePollMixin < Test::Unit::TestCase
  include FirePoll
  
  def test_can_be_mixed_in
    assert_nothing_raised do
      poll { true }
    end
  end
end
