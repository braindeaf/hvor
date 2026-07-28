class CreateHvorIpRanges < ActiveRecord::Migration[8.0]
  def change
    create_table :hvor_ip_ranges do |t|
      t.integer :ip_version, null: false
      t.bigint :ipv4_from
      t.bigint :ipv4_to
      t.string :ipv6_from, limit: 32, collation: ipv6_collation
      t.string :ipv6_to, limit: 32, collation: ipv6_collation
      t.string :country_code, limit: 2, null: false

      t.timestamps
    end

    add_index :hvor_ip_ranges, [ :ip_version, :ipv4_from ]
    add_index :hvor_ip_ranges, [ :ip_version, :ipv6_from ]
  end

  private

  # IPv6 bounds are stored as zero-padded lowercase hex strings so plain
  # string comparison matches numeric ordering. That only holds if the
  # column collates by byte value, so pin a binary-order collation on
  # adapters whose default collation could reorder alphanumerics.
  def ipv6_collation
    case connection.adapter_name.downcase
    when /postg/ then "C"
    when /mysql/ then "ascii_bin"
    end
  end
end
