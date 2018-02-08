# Represents an object that periodically runs a task.
module Scheduleable

    protected

    def schedule
        1.minute
    end

    def task
        raise "No task is defined to be run periodically"
    end

    private

    def run!
        @task ||= Thread.new do
            while true
                begin
                    task
                    backoff = schedule
                    sleep(backoff)
                rescue Exception => e
                    backoff = backoff + [schedule, 5.minutes].min
                    print "Event exception for #{self.class}:\n#{e}"
                    print "Backing off for #{backoff.to_i / 60} minutes"
                    sleep(backoff)
                end
            end
        end.run
    end

end
