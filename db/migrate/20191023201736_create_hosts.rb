# frozen_string_literal: true

class CreateHosts < ActiveRecord::Migration[6.0]
  def change
    create_table :hosts, id: :uuid do |t|
      t.string :name
      t.index  "LOWER(name)", unique: true, name: "unique-host-name"

      t.timestamps
    end
  end
end
