class NetBox < Liza::NetBox

  adapters do
    # Set up your adapter panel per the DSL in http://guides.lizarb.org/panels/adapter.html

    set :redis_url, "redis://localhost:6379/15"
    set :sqlite, "tmp/app.#{Time.now.to_i}.sqlite" if App.mode == :code
    set :sqlite, "app.#{App.mode}.sqlite"

  end

  databases do
    # Set up your database panel per the DSL in http://guides.lizarb.org/panels/database.html

    define :redis, RedisDb.current
    define :sql, SqliteDb.current
    define :sqlite, SqliteDb.current

  end

end
