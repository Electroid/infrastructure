require "minecraft/protocol/data"

module Minecraft
    module Protocol
        module Packet
            module Serverbound
                def direction
                    :serverbound
                end
            end

            module Clientbound
                def direction
                    :clientbound
                end
            end

            class << self
                def hash(value = nil, &block)
                    if block_given?
                        Hash.new{|h, k| h[k] = block[k] }
                    else
                        Hash.new(value)
                    end
                end

                def packets
                    # protocol -> direction -> packet_id -> class
                    @packets ||= hash{ hash{ {} } }
                end

                def read(io, protocol, direction)
                    decoder = Decoder.new(io)
                    decoder.varint # length
                    decoder.varint # ID
                    packet_id = decoder.values[1]

                    unless cls = Packet.packets[protocol.to_sym][direction.to_sym][packet_id]
                        raise "Unknown packet #{protocol}:#{direction}:#{packet_id}"
                    end

                    decoder.values.clear
                    cls.transcode_fields(decoder)
                    cls.new(*decoder.values)
                end
            end

            class Base
                class << self
                    attr :packet_id

                    def id(packet_id)
                        @packet_id = packet_id
                        Packet.packets[protocol][direction][packet_id] = self
                    end

                    def fields
                        @fields ||= {}
                    end

                    def field(name, type)
                        index = fields.size
                        fields[name.to_sym] = type.to_sym

                        define_method name do
                            @values[index]
                        end

                        define_method "#{name}=" do |value|
                            @values[index] = value
                        end
                    end

                    def transcode_fields(stream)
                        fields.values.each do |type|
                            stream.__send__(type)
                        end
                    end
                end

                def initialize(*values, **fields)
                    @values = values
                    self.class.fields.each do |name, _|
                        @values << fields[name]
                    end
                end

                def write(io)
                    io.write(encode)
                end

                def encode
                    encoded = ""
                    encoder = Encoder.new(StringIO.new(encoded))
                    encoder.values << self.class.packet_id
                    encoder.values.concat(@values)

                    encoder.varint # packet_id
                    self.class.transcode_fields(encoder)

                    prefix = ""
                    encoder = Encoder.new(StringIO.new(prefix))
                    encoder.values << encoded.size
                    encoder.varint # length

                    prefix + encoded
                end
            end

            module Handshaking
                class Base < Packet::Base
                    def self.protocol
                        :handshaking
                    end
                end

                module In
                    class Base < Handshaking::Base
                        extend Serverbound
                    end

                    class SetProtocol < Base
                        id 0
                        field :protocol_version, :varint
                        field :server_address, :string
                        field :server_port, :ushort
                        field :next_state, :varint
                    end
                end

                module Out
                    class Base < Handshaking::Base
                        extend Clientbound
                    end
                end
            end

            module Status
                class Base < Packet::Base
                    def self.protocol
                        :status
                    end
                end

                module In
                    class Base < Status::Base
                        extend Serverbound
                    end

                    class Start < Base
                        id 0
                    end

                    class Ping < Base
                        id 1
                        field :payload, :long
                    end
                end

                module Out
                    class Base < Status::Base
                        extend Clientbound
                    end

                    class ServerInfo < Base
                        id 0
                        field :json, :string
                    end

                    class Pong < Base
                        id 1
                        field :payload, :long
                    end
                end
            end

        end
    end
end
