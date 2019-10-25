# frozen_string_literal: true

class RelatedHostFilter
  include CallInterface

  Schema = Dry::Schema.Params do
    required(:hosts).value(array[:string])
    required(:scope).value(type?: ActiveRecord::Relation)
  end

  def call(input)
    params = yield Schema.call(input)

    query = DnsRecord.joins(:hosts)
      .where.not(hosts: { name: params[:hosts] })
      .where(id: params[:scope].reselect(:id))
      .group("hosts.id, hosts.name")
      .select("hosts.id, hosts.name, COUNT(*) AS count")

    Success(entries: query)
  end
end
