require "test/unit"
require "fire_poll"

class PatientlyTest < Test::Unit::TestCase
  def test_should_run_block_and_return_value
    result = FirePoll.patiently do "hi there" end
    assert_equal "hi there", result
  end

  def test_should_not_invoke_the_block_more_than_once_if_success
    call_count = 0
    result = FirePoll.patiently do 
      call_count += 1
      "hi again" 
    end
    assert_equal "hi again", result
  end

  def test_should_invoke_multiple_times_until_exceptions_cease
    call_count = 0
    result = FirePoll.patiently do 
      call_count += 1
      raise "minor fail" if call_count < 3
      "ok done" 
    end
    assert_equal result, "ok done"
    assert_equal 3, call_count
  end

  def test_should_invoke_multiple_times_then_raise_last_exception_if_errors_never_cease
    call_count = 0
    begin
      FirePoll.patiently(0.5) do 
        call_count += 1
        raise "persistent fail"
      end
      raise "Didn't expect patiently to return! call_count: #{call_count}"
    rescue => e
      assert_equal "persistent fail", e.message
    end
  end

  def test_should_delay_slightly_before_reinvocation
    ticks = []
    begin
      FirePoll.patiently(0.5) do 
        ticks << Time.now
        raise "more persistent fail"
      end
      raise "Didn't expect patiently to return!"
    rescue 
      ticks.each_cons(2).with_index do |times,i|
        before,after = times
        assert ((after-before) > 0.005), "time between reinvocations should be bigger than 50 ms (checking gap #{i})"
      end
    end
  end

  def test_should_default_to_5_seconds_max_patience_if_no_timeout_specified
    start = Time.now
    begin
      FirePoll.patiently do 
        raise "big fail"
      end
      raise "Didn't expect patiently to return!"
    rescue 
      span = Time.now-start
      diff = (5 - span).abs
      assert diff < 0.5, "Expected about 5 seconds to pass before giving up, got #{span} (diff of #{diff})"
    end
  end

  def test_should_pay_attention_to_actual_time_elapsed_when_deciding_patience_is_up
    start = Time.now
    call_count = 0
    begin
      # If something inside the block consumes significant time, don't get caught in a repeater 
      FirePoll.patiently(0.5) do 
        call_count += 1
        sleep 0.35 # more than half
        raise "sleepy fail"
      end
      raise "Didn't expect patiently to return! call_count=#{call_count}"
    rescue 
      assert_equal 2, call_count, "Delaying should have cut the iterations down to 2"
    end
  end

end
