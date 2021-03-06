require 'docker'

module Pencil
  class Docker

    def initialize(hostname = 'localhost')
      @hostname = hostname
    end

    def all
      containers = inspect_containers(list_running_containers)
      containers.each_with_object({}) do |container, acc|

        ports = container['NetworkSettings']['Ports']
        image = container['Config']['Image']
        cid = container['Id']

        ports.each do |service_port, host_port|
          unless host_port.nil?
            acc[cid] = {}
            acc[cid]['service_port'] = service_port.split('/').first
            acc[cid]['host_port'] = host_port.first['HostPort']
            acc[cid]["image"] = image
          end
        end

      end
    end

    private
    attr_accessor :hostname

    def list_running_containers
      ::Docker::Container.all
    end

    def inspect_containers(containers)
      containers.each_with_object([]) do |container, acc|
        acc << container.json
      end
    end
  end
end
