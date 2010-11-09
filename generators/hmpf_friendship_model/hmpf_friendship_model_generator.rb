# Shamelessly derived the original has many friends plugin
class HmpfFriendshipModelGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false

  def manifest
    record do |m|
      m.file "models/friendship.rb", "app/models/friendship.rb"
      m.migration_template "migrate/create_friendships.rb", "db/migrate"
    end
  end

  def file_name
    "create_friendships"
  end

end
