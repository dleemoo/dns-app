# frozen_string_literal: true

module Seeds
  class Populate
    def self.call
      ips.each { |ip| DnsRecord.create!(ip: ip) }
      hosts.each { |host| Host.create!(name: host) }

      associations.each do |ip, hosts|
        hosts.each do |host_name|
          DnsRecordHost.create!(
            dns_record: DnsRecord.find_by_ip(ip),
            host: Host.find_by_name(host_name)
          )
        end
      end
    end

    def self.ips
      %w[1.1.1.1 2.2.2.2 3.3.3.3 4.4.4.4 5.5.5.5]
    end

    def self.hosts
      %w[amet.com dolor.com ipsum.com lorem.com sit.com]
    end

    def self.associations
      {
        "1.1.1.1" => %w[lorem.com ipsum.com dolor.com amet.com],
        "2.2.2.2" => %w[ipsum.com],
        "3.3.3.3" => %w[ipsum.com dolor.com amet.com],
        "4.4.4.4" => %w[ipsum.com dolor.com sit.com amet.com],
        "5.5.5.5" => %w[dolor.com sit.com]
      }
    end
  end
end
