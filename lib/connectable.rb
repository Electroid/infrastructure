require "net/ssh/simple"

# Represents a SSH-able physical or virtual server.
module Connectable

    # Get the IPv4 address of this server.
    # Must be set by the implementer using @ip = "value".
    def ip
        @ip
    end

    # Get whether the connection is alive and the server is online.
    def alive?
        ping > 0
    end

    # Get the latency of the connection in number of seconds.
    # If the connection is not alive, this will return -1. 
    def ping
        start = Time.now
        execute("uptime")
        Time.now - start
    rescue
        -1
    end

    # Block the current thread until the connection is alive.
    # An exception will be thrown if not connected after 60 seconds.
    def ensure!
        for i in 1..12
            return if alive?
            sleep(5.seconds)
        end
        raise "Unable to wait for machine to accept connections"
    end

    # Get a hash of the cpu, memory, and swap memory utilization from [0,1].
    # This will only work for specific versions of Linux, and is
    # not tested on other platforms.
    def utilization
        {
            cpu: execute("grep 'cpu ' /proc/stat | awk '{print ($2+$4)/($2+$4+$5)}'"),
            memory: execute("free | grep Mem | awk '{print $3/$2}'"),
            swap: execute("free | grep Swap | awk '{print $3/$2}'")
        }
    end

    # Remotely execute a shell-based command and return the output.
    def execute(command)
        session.ssh(ip, command).stdout
    end

    # Copy a remote file to a local file.
    def copy(remote_path, local_path)
        session.scp_get(ip, remote_path, local_path)
    end

    # Upload a local file and paste to a remote file.
    def paste(local_path, remote_path)
        session.scp_put(ip, local_path, remote_path)
    end

    protected

    # Get the current, non-thread-safe SSH session.
    def session
        Thread.current[:"#{ip}_ssh"] ||= Net::SSH::Simple.new({:user => "root"})
    end
end
