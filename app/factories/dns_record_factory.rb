# frozen_string_literal: true

require "resolv"

class DnsRecordFactory
  include CallInterface

  Schema = Dry::Schema.Params do
    required(:ip).filled(:string).filter(format?: Resolv::IPv4::Regex)
    required(:hostname_attributes).array(:str?)
  end

  def call(input)
    params = yield Schema.call(input)

    DnsRecord.transaction do
      hosts = yield create_hosts(params[:hostname_attributes])
      dns_record = yield create_dns_record(params[:ip])
      Success(associate(dns_record, hosts))
    end
  rescue ActiveRecord::RecordNotUnique
    Failure("DnsRecord already present")
  end

  private

  def create_hosts(names)
    Success(names.map { |name| Host.find_or_create_by!(name: name) })
  end

  def create_dns_record(ip)
    Success(DnsRecord.create!(ip: ip))
  end

  def associate(dns, hosts)
    hosts.each { |host| DnsRecordHost.create!(host: host, dns_record: dns) }
    dns.reload
  end
end
