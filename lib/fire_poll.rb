# see the {file:README.md README file} for instruction on how to use this library
module FirePoll
  # @param [String] msg a custom message raised when polling fails
  # @param [Numeric] seconds number of seconds to poll
  # @yield a block that determines whether polling should continue
  # @yieldreturn false if polling should continue
  # @yieldreturn true if polling is complete
  # @raise [RuntimeError] when polling fails
  # @return the return value of the passed block
  # @since 1.0.0
  def poll(msg=nil, seconds=2.0) 
    (seconds * 10).to_i.times do 
      result = yield
      return result if result
      sleep 0.1
    end
    msg ||= "polling failed after #{seconds} seconds" 
    raise msg
  end

  module_function :poll

  #
  # Runs a block of code and returns the value.
  # IF ANYTHING raises in the block due to test failure or error,
  # the exception will be held, a small delay, then re-try the block.
  # This patience endures for 5 seconds by default, before the most
  # recent reason for failure gets re-raised.
  #
  def patiently(time=nil,&block)
    time ||= 5                   # 5 seconds overall patience
    give_up_at = Time.now + time # pick a time to stop being patient
    delay = 0.1                  # wait a tenth of a second before re-attempting
    failure = nil                # record the most recent failure

    while Time.now < give_up_at do
      begin
        return block.call
      rescue Exception => e
        failure = e
        sleep delay              # avoid spinning like crazy
      end
    end
    
    if failure
      raise failure # if we never got satisfaction, tell the world
    end
  end
  module_function :patiently
end
