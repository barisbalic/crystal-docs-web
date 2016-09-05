module Crystal::Docs
  class User
    getter name : String
    getter username : String
    @username = ""

    def initialize(user : GitHub::User)
      @username = user.login
      @name = user.name
      @home_dir = "/var/www/#{@username}"
    end

    def exists?
      System.user_exists?(@username)
    end

    def save(github_keys : Array(GitHub::Key))
      image_path = "/var/vfs/#{@username}.ext4"

      System.create_vfs(image_path, 5)
      System.create_fstab_entry(image_path, @home_dir)
      System.mount(@home_dir)
      System.add_user(@username, @home_dir)
      System.write_authorized_keys(@home_dir, github_keys)
      System.chown_r(@username, @home_dir)
    end

    def update(github_keys : Array(GitHub::Key))
      System.write_authorized_keys(@home_dir, github_keys)
      System.chown_r(@username, @home_dir)
    end
  end
end
