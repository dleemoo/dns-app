# frozen_string_literal: true

class DnsRecordFilter
  include CallInterface

  Schema = Dry::Schema.Params do
    required(:included).value(array[:string])
    required(:excluded).value(array[:string])
  end

  def call(input)
    params = yield Schema.call(input)

    query = apply_filters(DnsRecord.joins(:hosts), params)

    Success(
      entries: query.distinct.select(:id, :ip),
      total_records: query.distinct.count(:dns_record_id)
    )
  end

  private

  def apply_filters(query, params)
    if params[:included].present?
      query = query
        .where(dns_record_hosts: { id: included_subquery(params[:included]) })
    end

    if params[:excluded].present?
      query = query
        .where.not(id: excluded_subquery(params[:excluded]))
    end

    query
  end

  def included_subquery(hosts)
    DnsRecordHost
      .joins(:host)
      .where(hosts: { name: hosts })
      .group("dns_record_hosts.dns_record_id")
      .having("COUNT(*) = ?", hosts.count)
      .select("UNNEST(ARRAY_AGG(dns_record_hosts.id))")
  end

  def excluded_subquery(hosts)
    DnsRecordHost
      .joins(:host)
      .where(hosts: { name: hosts })
      .select("dns_record_id")
  end
end
