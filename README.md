Description
===========
`FirePoll.poll` is a method for knowing when something is ready. When your block yields true, execution continues. When your block yields false, poll keeps trying until it gives up and raises an error.

`FirePoll.patiently` extends this idea to letting your assertion(s) achieve success after a few tries, if necessary.

Examples: poll
--------------
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

Example: patiently
------------------
I'm writing tests for my web app which uses a bunch of crazy Ajax to fetch data from a service and populate a table... one row at a time.
In real life it takes just a moment to complete, but sometimes one or two of the rows hang for a second before continuing.

    it "loads the tasks asynchronously and fills the table" do
      go_to_task_list_page

      patiently do
        read_task_table_row(1).should == [ "Ride bike", "Done" ]
        read_task_table_row(2).should == [ "Write code", "Done" ]
        read_task_table_row(3).should == [ "Go to The Meanwhile", "Todo" ]
      end
    end

This test clearly shows what you're interested in, without getting tripped up by delayed Ajax results, but without adding unneeded synchronization or sleep code.


Usage
-----
Pass a block to `FirePoll.poll`. Return `true` when your need is met. Return `false` when it isn't. `poll` will raise an exception after too many failed attempts.

The `poll` method takes two optional parameters: a specific message to raise on failure and the number of seconds to wait. By default, `poll` will try for two seconds. `poll` runs every tenth of a second.

    FirePoll.poll { ... } # raises an error after two seconds
    FirePoll.poll("new data hasn't arrived from the device") { ... } # raises a friendlier error message
    FirePoll.poll("waited for too long!", 7) { ... } # raises an error after seven seconds with a specific error message
    FirePoll.poll(nil, 88) { ... } # raises an error after eighty-eight seconds with the generic error message

`FirePoll.patiently` is similar, but instead focuses on error-free execution of arbitrary code or tests.  If the passed block runs without raising an error, execution proceeds normally.  If an error is raised, the block is rerun after a brief delay, until the block can be run without exceptions.  If exceptions continue to raise, `patiently` gives up after a bit (default 5 seconds) by re-raising the most recent exception raised by the block.

The `FirePoll` module may be mixed into your class via `include` for nicer reading.

    FirePoll.poll { ... } # returns immedialtely if no errors, or as soon as errors stop
    FirePoll.poll(10) { ... } # increase patience to 10 seconds
    FirePoll.poll(20, 3) { ... } # increase patience to 20 seconds, and delay for 3 seconds before retry

RSpec
-----
We tend to include the FirePoll module up-front for all our specs:

    RSpec.configure do |config|
      config.include FirePoll
      ...
    end

Implementation
--------------
`poll` and `patiently` are both wall-clock sensitive now, meaning they will not poll longer than their allotted time. This means if your blocks spend significant time determining truth or success, these methods no longer suffer from the multiplicative effects of up-front loop-count calculation.

Motivation
----------
We frequently need to wait for something to happen - usually in tests. And we usually don't have any strict time requirements - as long as something happens in _about_ [x] seconds, we're happy. `poll` and `patiently` are cover a lot of ground quickly and cleanly.

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
* © 2012 [Atomic Object](http://www.atomicobject.com/)
* More Atomic Object [open source](http://www.atomicobject.com/pages/Software+Commons) projects