module Crystal::Docs
  class System
    def self.create_vfs(path : String, size : Int32)
      system("dd if=/dev/zero of=#{path} bs=1M count=#{size}")
      system("mkfs.ext4 #{path} -F")
    end

    def self.create_fstab_entry(vfs_path : String, mount_point : String)
      Dir.mkdir(mount_point) unless Dir.exists?(mount_point)
      entry = "#{vfs_path}    #{mount_point} ext4 rw,loop,usrquota,grpquota  0 0"
      system("echo \"#{entry}\" >> /etc/fstab")
    end

    def self.mount(target : String)
      system("mount #{target}")
    end

    def self.write_authorized_keys(path : String, keys : Array(GitHub::Key))
      key_file_path = File.join(path, ".ssh")
      key_file = File.join(key_file_path, "authorized_keys")
      authorized_keys = keys.map {|k| k.body }.join("\n")

      Dir.mkdir(key_file_path) unless Dir.exists?(key_file_path)
      File.delete(key_file) if File.exists?(key_file)
      File.write(key_file, authorized_keys)
    end

    def self.add_user(username : String, home_dir : String)
      system("useradd #{username} -d #{home_dir} --password ABCDE --shell /usr/bin/rssh")
    end

    def self.chown_r(owner : String, path : String)
      system("chown -R #{owner}:#{owner} #{path}")
    end

    def self.user_exists?(username : String)
      system("id -u #{username}")
    end

    def self.quiet(command : String)
      system("#{command} > /dev/null 2>&1")
    end
  end
end
