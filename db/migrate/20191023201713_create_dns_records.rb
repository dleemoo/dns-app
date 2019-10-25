# frozen_string_literal: true

class CreateDnsRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :dns_records, id: :uuid do |t|
      t.string :ip
      t.index  :ip, unique: true

      t.timestamps
    end
  end
end
