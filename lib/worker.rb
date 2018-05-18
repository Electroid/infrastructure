require "workers"

# Represents a task that is run periodically in a background thread.
class Worker

    # Create a new background thread that calls #{run} every #{frequency}.
    # This does not block the current thread, but exceptions will
    # pass all the way to the main thread.
    def run!(frequency=1.minute)
        raise "Worker is already running" if @timer
        log("Running every #{frequency.to_i} seconds")
        Thread.abort_on_exception = true # Ensure exceptions pass to main thread
        run # Run the code for the first time
        @timer = Workers::PeriodicTimer.new(frequency.to_i) do
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
end
