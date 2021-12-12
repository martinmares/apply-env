require "colorize"
require "option_parser"

module ApplyEnv
  VERSION = "1.0.0"

  class EnvMatch
    getter :orig, :name, :value, :found

    @name : String = ""
    @value : String = ""
    @found : Bool = false

    def initialize(@orig : String)
      parse(@orig)
    end

    def found?
      @found
    end

    private def parse(orig : String)
      match = /(\{\{\s*\.Env\.)(\w+)(\s*\}\})/ix.match(orig)
      if match
        @name = match[2] if match[2]?
        if ENV.has_key? @name
          @value = ENV[@name]
          @found = true
        end
      end
    end
  end

  class Template
    getter :file_name, :content, :new_content

    @file_name : String
    @debug : Bool
    @content : String
    @env_matches : Array(EnvMatch)

    def initialize()
      opts = parse_opts()
      @file_name = opts[:file_name]
      @debug = if opts.has_key?(:debug)
        opts[:debug].downcase.starts_with?("true")
      else
        false
      end
      @content = ""
      @env_matches = Array(EnvMatch).new
    end

    def parse_opts : Hash(Symbol, String)
      result = Hash(Symbol, String).new
      OptionParser.parse do |parser|
        parser.banner = "Usage: apply_env [arguments]"
        parser.on("-f NAME", "--file=NAME", "Specifies template file name") { |name| result[:file_name] = name }
        parser.on("-d", "--debug", "Debug?") { result[:debug] = "true" }
        # parser.on("-d DEBUG", "--debug=DEBUG", "Debug? [true || false]") { |debug| result[:debug] = debug }
        parser.on("-v", "--version", "App version") do
          puts "App name: apply_env"
          puts "App version: #{VERSION}"
          exit
        end
        parser.on("-h", "--help", "Show this help") do
          puts parser
          exit
        end
        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option."
          STDERR.puts parser
          exit(1)
        end
  
      end
      unless result.has_key?(:file_name)
        puts "File (name must be specified!".colorize(:red)
        exit(1)
      end
      result
    end

    def find_env_matches : Array(String)
      result = Array(String).new
      if @content
        @content.scan(/\{\{\s*\.Env\.\w+\s*\}\}/ix).each do |match|
          result << match[0] if match.size == 1
        end
      end
      result
    end

    def exists?
      File.exists? @file_name
    end

    def load_content : String
      if exists?
        @content = File.read(@file_name)
      else
        @content = ""
      end
    end

    def render : String
      @content = load_content()
      env_matches = find_env_matches()
      env_matches.each_with_index do |m, i|
        env_match = EnvMatch.new(m)
        @env_matches << env_match
        puts "Found [#{i}], orig: \"#{m.to_s.colorize(:yellow)}\", env_var: #{env_match.value.colorize(:green)}" if @debug
      end
      new_content = @content
      @env_matches.each do |env_match|
        new_content = new_content.gsub(env_match.orig, env_match.value) if env_match.found?
      end
      new_content
    end

  end

  template = Template.new() # "#{t1}, #{t2}"
  result = template.render()
  puts result
end
