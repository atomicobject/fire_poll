Description
===========
`FirePoll.poll` is a method for knowing when something is ready. When your block yields true, execution continues. When your block yields false, poll keeps trying until it gives up and raises an error.

Examples
--------
I'm writing a system test for a web application. My test simulates uploading a large file, which isn't instantaneous. I need to know when the file has finished uploading so I can start making assertions.
    def wait_for_file(filename)
      FirePoll.poll do
        FileStore.file_ready?(filename)
      end
    end
    
    def test_files_are_saved
      upload_file "blue.txt"
      assert_nothing_raised { wait_for_file "blue.txt" }
      assert_equal "blue is the best color", read_saved_file("blue.txt")
    end

I just fired up a fake web service to respond to my client application. I want to know when the service is online before I start the client tests. I'm willing to wait 10 seconds before giving up.
    class TestHelper
      include FirePoll

      def wait_for_server
        poll("server didn't come online quick enough", 10) do
          begin
            TCPSocket.new(SERVER_IP, SERVER_PORT)
            true
          rescue Exception
            false
          end
        end
      end
    end

Usage
-----
Pass a block to `FirePoll.poll`. Return `true` when your need is met. Return `false` when it isn't. `poll` will raise an exception after too many failed attempts.

The `poll` method takes two optional parameters: a specific message to raise on failure and the number of seconds to wait. By default, `poll` will try for two seconds. `poll` runs every tenth of a second.
    FirePoll.poll { ... } # raises an error after two seconds
    FirePoll.poll("new data hasn't arrived from the device") { ... } # raises a friendlier error message
    FirePoll.poll("waited for too long!", 7) { ... } # raises an error after seven seconds with a specific error message
    FirePoll.poll(nil, 88) { ... } # raises an error after eighty-eight seconds with the generic error message

The `FirePoll` module may be mixed into your class; this makes it a little faster to type the method name.
    class TestHelper
      include FirePoll
      def helper_method
        poll do
          ...
        end
      end
    end

Implementation
--------------
`FirePoll.poll`'s implementation isn't partcilarly accurate with respect to time. The method will run your block (number of seconds * 10) times. It sleeps for a tenth of a second between attempts. Since it doesn't keep track of time, if your timing needs require accuracy, you'll need to look elsewhere.

Motivation
----------
We frequently need to wait for something to happen - usually in tests. And we usually don't have any strict time requirements - as long as something happens in _about_ [x] seconds, we're happy. `FirePoll.poll` meets our need nicely.

On a related note, `Timer::Timeout` is known to be [busted](http://ph7spot.com/musings/system-timer) and [unreliable](http://blog.headius.com/2008/02/rubys-threadraise-threadkill-timeoutrb.html). `FirePoll.poll` doesn't employ any threads or timers, so we don't worry about whether it will work or not.

TODO
----
* Nice to have: hook into Test::Unit and RSpec instead of raising a Ruby exception
* Nice to have: pass options as a hash instead of two parameters. This will look nice with Ruby 1.9's hash syntax.

Authors
=======
* Matt Fletcher (fletcher@atomicobject.com)
* David Crosby (crosby@atomicobject.com)
* Micah Alles (alles@atomicobject.com)
* © 2011 [Atomic Object](http://www.atomicobject.com/)
* More Atomic Object [open source](http://www.atomicobject.com/pages/Software+Commons) projects
