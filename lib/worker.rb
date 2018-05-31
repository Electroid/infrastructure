require "workers"
require "environment"
require "active_support/time"

# Represents a task that is run periodically in a background thread.
class Worker

    # Ensure exceptions pass to main thread
    Thread.abort_on_exception = true

    # Create a new background thread that calls #{run} every period of time.
    # This does not block the current thread, but exceptions will
    # pass all the way to the main thread.
    def run!(every=1.minute)
        raise "Worker is already running" if @timer
        log("Running every #{every.to_i} seconds")
        run # Run the code for the first time.
        @timer = Workers::PeriodicTimer.new(every.to_i) do
            run
        end
    end

    # Stop the background thread of this worker.
    def stop!
        raise "Worker is not currently running" unless @timer
        @timer.cancel
        @timer = nil
        log("Has been stopped")
    end

    protected

    def log(message)
        print "[#{Time.now.to_formatted_s(:long_ordinal)}] [#{self.class.name}] #{message}\n"
    end

    private

    def run
        raise NotImplementedError, "Worker has no code to run"
    end

    class << self
        def worker(value=[])
            @@worker ||= value
        end

        def worker?
            Env.has?("worker")
        end

        def static_template(*args, every: 1.minute)
            worker([self, every, *args])
        end

        def template(expected, every: 1.minute, i: 0)
            received = ARGV.map{|arg| arg.split("=")}.to_h
            args = Array.new(expected.size)
            expected.each do |key, val|
                args[i] = received[key.to_s] || val or \
                          raise "Missing worker argument '#{key}'"
                i += 1
            end
            args.compact!
            worker([self, every, *args])
        end
    end

    # If the script is a worker, block the program from exiting naturally.
    END {
        if worker?
            clazz, every, *args = worker
            (args.empty? ? clazz.new
                         : clazz.new(*args)).run!(every)
            while true
                sleep(1.day)
            end
        else
            worker(nil)
        end
    }
end
