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
end
