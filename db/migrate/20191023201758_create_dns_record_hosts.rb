# frozen_string_literal: true

class CreateDnsRecordHosts < ActiveRecord::Migration[6.0]
  def change
    create_table :dns_record_hosts, id: :uuid do |t|
      t.references :dns_record, null: false, foreign_key: true, type: :uuid
      t.references :host,       null: false, foreign_key: true, type: :uuid

      t.index %i[dns_record_id host_id],
              unique: true, name: "unique-dns-association"

      t.timestamps
    end
  end
end
