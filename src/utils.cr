module ApplyEnv

  class Utils

    def self.with_file(file_name, mode)
      File.open(Path[file_name], mode) do |f|
        yield(f)
      end
    end

  end

end
