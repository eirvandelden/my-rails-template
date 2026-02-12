say "Setting up database structure...", :blue

# Create storage/db/ directory
empty_directory "storage/db"
create_file "storage/db/.gitkeep"

# Update database.yml to use storage/db/ instead of db/
gsub_file "config/database.yml",
  /development:\n  <<: \*default\n  database: db\/development\.sqlite3/,
  "development:\n  <<: *default\n  database: storage/db/development.sqlite3"

gsub_file "config/database.yml",
  /test:\n  <<: \*default\n  database: db\/test\.sqlite3/,
  "test:\n  <<: *default\n  database: storage/db/test.sqlite3"

# Update .gitignore to ignore databases in storage/db/
append_to_file ".gitignore", "\n# SQLite databases in storage\n/storage/db/*.sqlite3\n/storage/db/*.sqlite3-*"

# Remove old db/*.sqlite3 entries from .gitignore if they exist
gsub_file ".gitignore",
  /\/db\/\*\.sqlite3\n\/db\/\*\.sqlite3-\*/,
  ""

say "✓ Database structure configured", :green
say "  SQLite databases will be stored in storage/db/", :white
say "  Keep db/ directory for migrations and schema only", :white
