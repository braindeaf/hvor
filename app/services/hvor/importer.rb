require "zip"
require "csv"

module Hvor
  class ImportError < StandardError; end

  # Streams IP2Location LITE CSV rows out of a downloaded zip archive and
  # performs an atomic dump-and-repopulate of Hvor::IPRange.
  #
  # Both files are fully parsed into batches *before* the database is
  # touched, so a failure downloading/parsing the second file never leaves
  # the table half-populated, and the transaction itself holds no network
  # I/O (just delete_all + insert_all).
  class Importer
    def initialize(batch_size: Hvor.configuration.import_batch_size)
      @batch_size = batch_size
    end

    def import(ipv4_zip:, ipv6_zip:)
      timestamp = Time.current
      ipv4_batches = read_batches(ipv4_zip, ip_version: 0, timestamp: timestamp) { |row| ipv4_attributes(row) }
      ipv6_batches = read_batches(ipv6_zip, ip_version: 1, timestamp: timestamp) { |row| ipv6_attributes(row) }

      Hvor::IPRange.transaction do
        Hvor::IPRange.delete_all
        ipv4_batches.each { |batch| Hvor::IPRange.insert_all(batch) }
        ipv6_batches.each { |batch| Hvor::IPRange.insert_all(batch) }
      end
    end

    private

    attr_reader :batch_size

    def read_batches(zip_file, ip_version:, timestamp:)
      batches = []

      each_csv_row(zip_file) do |slice|
        batches << slice.map do |row|
          yield(row).merge(ip_version: ip_version, created_at: timestamp, updated_at: timestamp)
        end
      end

      batches
    end

    def each_csv_row(zip_file)
      Zip::File.open(zip_file.path) do |zip|
        entry = zip.entries.find { |e| e.name.downcase.end_with?(".csv") } || zip.entries.first
        raise ImportError, "#{zip_file.path} does not contain a CSV entry" unless entry

        entry.get_input_stream do |io|
          CSV.new(io, headers: false).each_slice(batch_size) { |slice| yield slice }
        end
      end
    end

    def ipv4_attributes(row)
      { ipv4_from: Integer(row[0], 10), ipv4_to: Integer(row[1], 10), country_code: row[2] }
    end

    def ipv6_attributes(row)
      { ipv6_from: hex(row[0]), ipv6_to: hex(row[1]), country_code: row[2] }
    end

    def hex(decimal_string)
      Integer(decimal_string, 10).to_s(16).rjust(32, "0")
    end
  end
end
