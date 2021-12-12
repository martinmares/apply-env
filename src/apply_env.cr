require "colorize"
require "option_parser"

module ApplyEnv
  VERSION = "1.0.0"

  class Template
    getter :file_name, :content

    @file_name : String
    @content : String

    def initialize()
      opts = parse_opts()
      @file_name = opts[:file_name]
      @content = ""
    end

    def parse_opts : Hash(Symbol, String)
      result = Hash(Symbol, String).new
      OptionParser.parse do |parser|
        parser.banner = "Usage: apply_env [arguments]"
        parser.on("-f NAME", "--file=NAME", "Specifies template file name") { |name| result[:file_name] = name }
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
      result
    end

    def find_env_matches : Array(String)
      result = Array(String).new
      @content.scan(/\{\{\s*\.Env\.\w+\s*\}\}/ix).each do |match|
        result << match[0] if match.size == 1
      end
      result
    end

    def exists?
      File.exists? @file_name unless @file_name.nil?
    end

    def load_content
      if exists?
        @content = File.read(@file_name)
      end
    end

    def render
      load_content()
      matches = find_env_matches()
      matches.each do |m|
        puts m
      end
    end

  end

  template = Template.new() # "#{t1}, #{t2}"
  template.render()
  # matches = template.find_env_matches()
  # puts "Reading content from template: #{template.file_name.to_s.colorize(:cyan)}"
  # puts "Found #{matches.size.to_s.colorize(:green)} strings to replace"
end
