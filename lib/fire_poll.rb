module FirePoll
  def poll(msg=nil, seconds=2.0) 
    (seconds * 10).to_i.times do 
      return if yield
      sleep 0.1
    end
    msg ||= "polling failed after #{seconds} seconds" 
    raise msg
  end

  module_function :poll
end
