say "Setting up database structure...", :blue

# Create storage/db/ directory
empty_directory "storage/db"
create_file "storage/db/.gitkeep"

# Rewrite config/database.yml with SQLite pragmas tuned to avoid
# "database is locked" errors under concurrent access: WAL journaling lets
# readers and a writer run concurrently, and timeout keeps writers waiting
# instead of failing immediately. Written directly (rather
# than patched via gsub) since Rails' generated defaults already changed
# shape across versions and a direct rewrite doesn't depend on matching them.
create_file "config/database.yml", <<~YAML, force: true
  # SQLite. Versions 3.8.0 and up are supported.
  #   gem install sqlite3
  #
  #   Ensure the SQLite 3 gem is defined in your Gemfile
  #   gem "sqlite3"
  #
  # journal_mode: wal lets readers and a writer proceed concurrently instead
  # of blocking each other. timeout configures sqlite3's Ruby-side busy handler,
  # so busy_timeout is intentionally not set as a pragma.
  default_pragmas: &default_pragmas
    journal_mode: wal
    synchronous: normal
    temp_store: memory
    mmap_size: 134217728
    cache_size: -20000
    wal_autocheckpoint: 10000

  default: &default
    adapter: sqlite3
    max_connections: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    timeout: 5000
    pragmas:
      <<: *default_pragmas

  development:
    <<: *default
    database: storage/db/development.sqlite3

  # Warning: The database defined as "test" will be erased and
  # re-generated from your development database when you run "rake".
  # Do not set this db to the same as development or production.
  #
  # Tests run multi-threaded (see test/test_helper.rb), so many threads share
  # this one file through a single connection pool. Timeouts are raised and
  # durability is relaxed (synchronous: OFF, no WAL auto-checkpointing)
  # since a test run doesn't need to survive a crash, it needs to not
  # spuriously fail with lock errors under load.
  test:
    <<: *default
    database: storage/db/test<%= ENV["TEST_ENV_NUMBER"] || ENV["TEST_WORKER_ID"] %>.sqlite3
    timeout: 20000
    pragmas:
      <<: *default_pragmas
      mmap_size: 268435456
      synchronous: "OFF"
      wal_autocheckpoint: 0

  # SQLite3 writes its data on the local filesystem, as such it requires
  # persistent disks. Production databases live under storage/db/, which is
  # part of storage/ and mounted as a persistent Docker volume by Kamal
  # (see config/deploy.yml).
  production:
    primary:
      <<: *default
      database: storage/db/production.sqlite3
    cache:
      <<: *default
      database: storage/db/production_cache.sqlite3
      migrations_paths: db/cache_migrate
    queue:
      <<: *default
      database: storage/db/production_queue.sqlite3
      migrations_paths: db/queue_migrate
    cable:
      <<: *default
      database: storage/db/production_cable.sqlite3
      migrations_paths: db/cable_migrate
YAML

# Update .gitignore: Rails' default `/storage/*` ignore swallows storage/db/
# entirely (including storage/db/.gitkeep) unless explicitly un-ignored.
append_to_file ".gitignore", <<~GITIGNORE

  # SQLite databases in storage/db/ (directory itself is tracked, files are not)
  !/storage/db/
  !/storage/db/.gitkeep
  /storage/db/*.sqlite3
  /storage/db/*.sqlite3-*
GITIGNORE

say "✓ Database structure configured", :green
say "  SQLite databases will be stored in storage/db/", :white
say "  WAL mode, timeout lock waits, and per-environment pragmas applied", :white
