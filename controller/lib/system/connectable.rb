require "net/ssh/simple"

# Represents a SSH-able physical or virtual machine.
module Connectable

    def ip
        @ip
    end

    def alive?
        ping > 0
    end

    def ping
        start = Time.now
        execute("uptime")
        Time.now - start
    rescue
        -1
    end

    def ensure!
        for i in 1..12
            return if alive?
            sleep(5.seconds)
        end
        raise "Unable to wait for machine to accept connections"
    end

    def utilization
        {
            cpu: execute("grep 'cpu ' /proc/stat | awk '{print ($2+$4)*100/($2+$4+$5)}'"),
            memory: execute("free | grep Mem | awk '{print $3/$2 * 100.0}'"),
            swap: execute("free | grep Swap | awk '{print $3/$2 * 100.0}'")
        }
    end

    def execute(command)
        session.ssh(ip, command).stdout
    end

    def copy(remote_path, local_path)
        session.scp_get(ip, remote_path, local_path)
    end

    def paste(local_path, remote_path)
        session.scp_put(ip, local_path, remote_path)
    end

    protected

    def session
        Thread.current[:"#{ip}_ssh"] ||= Net::SSH::Simple.new({:user => "root"})
    end

end
