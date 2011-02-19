Description
===========
`FirePoll.poll` is possibly the most brain-dead way of knowing when something is ready. That said, it's also the smallest and simplest I've encountered.

Usage
=====
Pass a block to `FirePoll.poll`. Return `true` when whatever you need is ready. Return `false` when it isn't. `poll` will raise an exception after too many failed attempts.

The `poll` method takes two optional parameters: a specific message to raise on failure and the number of seconds to wait. By default, `poll` will try for two seconds. `poll` runs every tenth of a second.
    FirePoll.poll { false } # raises an error after two seconds
    FirePoll.poll("don't return false every time, dumbass") { false } # raises a friendlier error message
    FirePoll.poll("waited for too long!", 7) { false } # raises an error after seven seconds with a specific error message
    FirePoll.poll(nil, 88) { false } # raises an error after eighty-eight seconds with the generic error message

The `FirePoll` module may be mixed into your class; this makes it a little faster to type `poll`.
    class TestHelper
      include FirePoll
      def helper_method
        poll do
          ...
        end
      end
    end

Examples
========
I'm writing a system test for a web application. My test simulates uploading a large file, which isn't instantaneous. I need to know when the file has finished uploading so I can start making assertions.
    def wait_for_file(filename)
      FirePoll.poll do
        FileStore.file_ready?(filename)
      end
    end
    
    def test_files_are_saved
      upload_file "blue.txt"
      assert_nothing_raised { wait_for_file "blue.txt" }
      assert_equal "blue is the best color", read_saved_file_contents("blue.txt")
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

Risks
=====
If you need accurate timing precision, look elsewhere. Poll simply sleeps for a tenth of a second between yields to the block. This means, generally speaking, it will take slightly longer to timeout than whatever time you pass. Most of the time it doesn't matter.

Motivation
==========
`Timer::Timeout` is known to be [busted](http://ph7spot.com/musings/system-timer) and [unreliable](http://blog.headius.com/2008/02/rubys-threadraise-threadkill-timeoutrb.html). And usually we don't need the level of precision it can provide. `FirePoll.poll` easily fits our minimal needs.

TODO
====
* Nice to have: hook into Test::Unit and RSpec instead of raising a Ruby exception
* Nice to have: pass options as a hash instead of two parameters. This will look nice with Ruby 1.9's hash syntax.

Authors
=======

* Matt Fletcher (fletcher@atomicobject.com)
* David Crosby (crosby@atomicobject.com)
* Micah Alles (alles@atomicobject.com)
* © 2011 [Atomic Object](http://www.atomicobject.com/)
* More Atomic Object [open source](http://www.atomicobject.com/pages/Software+Commons) projects
