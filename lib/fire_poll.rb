# see the {file:README.md README file} for instruction on how to use this library
module FirePoll
  # @param [String] msg a custom message raised when polling fails
  # @param [Numeric] seconds number of seconds to poll
  # @yield a block that determines whether polling should continue
  # @yield return false if polling should continue
  # @yield return true if polling is complete
  # @raise [RuntimeError] when polling fails
  # @return the return value of the passed block
  # @since 1.0.0
  def poll(msg=nil, seconds=nil) 
    seconds ||= 2.0                 # 5 seconds overall patience
    give_up_at = Time.now + seconds # pick a time to stop being patient
    delay = 0.1                     # wait a tenth of a second before re-attempting
    failure = nil                   # record the most recent failure

    while Time.now < give_up_at do
      result = yield
      return result if result
      sleep delay
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
  # @param [Numeric] seconds Wall-clock number of seconds to be patient, default is 5 seconds
  # @param [Numeric] delay Seconds to hesitate after encountering a failure, default is 0.1 seconds 
  # @yield a block that will be run, and if it raises an error, re-run until success, or patience runs out
  # @raise [Exception] the most recent Exception that caused the loop to retry before giving up.
  # @return the value of the passed block
  # @since 1.2.0
  #
  def patiently(seconds=nil, delay=nil)
    seconds ||= 5                   # 5 seconds overall patience
    give_up_at = Time.now + seconds # pick a time to stop being patient
    delay ||= 0.1                   # wait a tenth of a second before re-attempting
    failure = nil                   # record the most recent failure

    while Time.now < give_up_at do
      begin
        return yield
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
