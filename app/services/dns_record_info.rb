# frozen_string_literal: true

class DnsRecordInfo
  include CallInterface

  Schema = Dry::Schema.Params do
    optional(:included).value(array[:string])
    optional(:excluded).value(array[:string])
  end

  def call(input)
    params = yield Schema.call(input)

    dns_records = yield DnsRecordFilter.call(dns_record_params(params))
    related_hosts = yield RelatedHostFilter.call(
      related_host_params(params, dns_records[:entries])
    )

    Success(
      total_records: dns_records[:total_records],
      records: dns_records[:entries],
      related_hostnames: remove_ids(related_hosts[:entries])
    )
  end

  private

  def dns_record_params(params)
    { included: Array(params[:included]), excluded: Array(params[:excluded]) }
  end

  def related_host_params(params, scope)
    { hosts: Array(params[:included]) + Array(params[:excluded]), scope: scope }
  end

  # rails require the id when using select method and we don't desire that
  # present in the API output. So, we are filtering the id keys.
  def remove_ids(query)
    query.map { |record| record.attributes.slice("name", "count") }
  end
end
