# Hvor

*Hvor* ("where", in Danish) is a mountable Rails engine that imports
[IP2Location](https://lite.ip2location.com/) LITE CSV data (IPv4 and IPv6
ranges mapped to `country_code`) into an `Hvor::IPRange` table, and answers
"what country is this IP in?" via a cached lookup and a small JSON API.

## Installation

Add to your Gemfile:

```ruby
gem "hvor"
```

Then:

```bash
bundle
bin/rails generate hvor:install
bin/rails hvor:install:migrations
bin/rails db:migrate
```

The install generator writes `config/initializers/hvor.rb`. At minimum, set an
IP2Location LITE token there (or via the `IP2LOCATION_TOKEN` env var) — get
one free at https://lite.ip2location.com/.

## Populating IPRange

Enqueue `Hvor::ImportIpRangesJob` (on a daily/weekly schedule via whatever job
scheduler your app uses — IP2Location LITE data updates roughly monthly). It
downloads the IPv4 and IPv6 country CSV zips, and does an atomic
dump-and-repopulate of `Hvor::IPRange` — the table is only ever replaced once
both files have downloaded and parsed successfully.

```ruby
Hvor::ImportIpRangesJob.perform_later
```

## Looking up an IP

```ruby
Hvor.lookup("1.0.0.1")        # => "AU"
Hvor.lookup("::ffff:8.8.8.8") # => "US" (ipv4-mapped ipv6 is unwrapped to plain ipv4)
```

Results (including misses) are cached via `Rails.cache` for
`Hvor.configuration.cache_expires_in` (default 24 hours). A `country_code` of
`"-"` means the IP falls in an unallocated/private/reserved range (this is
IP2Location's own placeholder — e.g. `Hvor.lookup("127.0.0.1")` will
typically return `"-"`, not `nil`; `nil` means the IP simply isn't covered by
any imported range, which shouldn't happen once the table is populated).

## Mounted API

Mount the engine in your host app's routes:

```ruby
mount Hvor::Engine => "/hvor"
```

This exposes:

- `GET /hvor/lookup?ip=1.2.3.4` — `{"ip":"1.2.3.4","country_code":"AU"}`
- `GET /hvor/lookup/me` — same, but for the requesting client's own IP
  (`request.remote_ip`)

An invalid `ip` param returns `400` with `{"error": "..."}`.

## Configuration

```ruby
# config/initializers/hvor.rb
Hvor.configure do |config|
  config.api_token = ENV["IP2LOCATION_TOKEN"]
  config.ipv4_product_code = "DB1LITECSV"      # country-only LITE database
  config.ipv6_product_code = "DB1LITECSVIPV6"
  config.cache_store = -> { Rails.cache }
  config.cache_expires_in = 24.hours
  config.import_batch_size = 5_000
  config.download_timeout = 60
  config.queue_name = :hvor
end
```

## Database notes

`hvor_ip_ranges` stores IPv4 bounds as `bigint` and IPv6 bounds as a
zero-padded 32-character lowercase hex string (IPv6's 128-bit range doesn't
fit in a bigint), so lookups work identically on PostgreSQL, MySQL, and
SQLite. The migration pins a binary-order collation on the IPv6 columns
(`C` on Postgres, `ascii_bin` on MySQL) so string comparison matches numeric
ordering regardless of the database's default locale — if you're running
CI against a database other than SQLite, make sure that migration path gets
exercised at least once, since SQLite's default collation is already binary
and won't catch a regression here.

## License

MIT.
