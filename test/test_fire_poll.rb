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

  def test_the_result_of_the_block_is_returned
    result = FirePoll.poll { "this is the result of the block" }
    assert_equal "this is the result of the block", result
  end

  def test_should_pay_attention_to_actual_time_elapsed_when_deciding_whether_to_continue_polling
    start = Time.now
    call_count = 0
    begin
      # If something inside the block consumes significant time, don't get caught in a repeater 
      FirePoll.poll("woops", 0.5) do 
        call_count += 1
        sleep 0.35 # more than half
        false
      end
      raise "Didn't expect #poll to return! call_count=#{call_count}"
    rescue => e
      assert_equal "woops", e.message
      assert_equal 2, call_count, "Delaying should have cut the iterations down to 2"
    end
  end
end

