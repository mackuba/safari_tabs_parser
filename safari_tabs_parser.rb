require "sqlite3"

if ARGV.length == 0
  puts "Usage: #{$PROGRAM_NAME} <SafariTabs.db>"
  exit 1
end

filename = ARGV[0]

if !File.exist?(filename)
  puts "Error: no such file #{filename}"
  exit 1
end

db = SQLite3::Database.new(filename)

windows = db.execute <<-SQL
  SELECT windows.id, title, syncable, active_tab_group_id
  FROM windows
  LEFT JOIN bookmarks ON (windows.active_tab_group_id = bookmarks.id)
  WHERE is_last_session = 1
  ORDER BY windows.id
SQL

windows.each do |id, title, sync, group_id|
  puts (sync == 1) ? "[#{title}]" : "[Window #{id}]"

  query = <<-SQL
    SELECT title, url
    FROM bookmarks
    WHERE parent = ? ORDER BY order_index
  SQL

  db.execute(query, group_id) do |title, url|
    puts "- #{url}"
    puts "    #{title}"
  end

  puts
end
