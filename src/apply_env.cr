require "colorize"
require "option_parser"

module ApplyEnv
  VERSION = "1.1.0"

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
      match = /(\{\{\s*)(\w+)(\s*\}\})/ix.match(orig)
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
    @stdin : Bool

    def initialize()
      @stdin = true
      @debug = false
      @file_name = ""
      @content = ""
      @env_matches = Array(EnvMatch).new
      _opts = parse_opts()
    end

    private def read_from_stdin : String
      STDIN.gets_to_end
    end

    def parse_opts
      OptionParser.parse do |parser|
        parser.banner = "Usage: apply-env [arguments]"
        parser.on("-f NAME", "--file=NAME", "Specifies template file name") do |_name|
          @file_name = _name
          @stdin = false
        end
        parser.on("-d", "--debug", "Debug?") { @debug = true }
        parser.on("-v", "--version", "App version") do
          puts "App name: apply-env"
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
    end

    def find_env_matches : Array(String)
      result = Array(String).new
      if @content
        @content.scan(/\{\{\s*\w+\s*\}\}/ix).each do |match|
          result << match[0] if match.size == 1
        end
      end
      result
    end

    def load_content : String
      if @stdin
        @content = read_from_stdin()
      else
        @content = File.read(@file_name) if File.exists?(@file_name)
      end
      @content ||= ""
    end

    def render : String
      @content = load_content()
      env_matches = find_env_matches()
      env_matches.each_with_index do |m, i|
        env_match = EnvMatch.new(m)
        @env_matches << env_match
        puts "Found [#{i}], orig: \"#{m.to_s.colorize(:yellow)}\", apply with: \"#{env_match.value.colorize(:green)}\"" if @debug
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
