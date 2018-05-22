require "workers"
require "environment"

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
        def worker?
            Env.has?("worker")
        end

        def instance(*args, every: 1.minute)
            return unless worker?
            Workers::Timer.new(1.second) do
                new(args).run!(every)
            end
        end
    end

    # If the script is a worker, block the program from exiting naturally.
    END {
        while worker?
            sleep(1.day)
        end
    }
end
