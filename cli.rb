#!/usr/bin/ruby -w

class ProjectGenerator
    def initialize(project_name)
      @project_name = project_name
    end
  
    def create_project
      Dir.mkdir(@project_name)
      Dir.chdir(@project_name) do
        create_directories
        create_files
      end
    end
  
    private
  
    def create_directories
      %w(lib bin config test).each do |dir|
        Dir.mkdir(dir)
      end
    end
  
    def create_files
      File.write("config/environment.rb", environment_file)
      File.write("lib/#{@project_name}.rb", project_file)
      File.write("bin/#{@project_name}", executable_file)
      File.write("test/#{@project_name}_test.rb", test_file)
    end
  
    def environment_file
      <<~HEREDOC
      # config/environment.rb
      require 'bundler/setup'
      Bundler.require
  
      HEREDOC
    end
  
    def project_file
      <<~HEREDOC
      # lib/#{@project_name}.rb
      class #{@project_name.capitalize}
        # Your code goes here
      end
  
      HEREDOC
    end
  
    def executable_file
      <<~HEREDOC
      #!/usr/bin/env ruby
  
      require_relative '../lib/#{@project_name}'
  
      # Your code goes here
  
      HEREDOC
    end
  
    def test_file
      <<~HEREDOC
      # test/#{@project_name}_test.rb
      require 'minitest/autorun'
      require '#{@project_name}'
  
      class #{@project_name.capitalize}Test < Minitest::Test
        def test_something
          # Your test goes here
        end
      end
  
      HEREDOC
    end
end
  
if $PROGRAM_NAME == __FILE__
project_name = ARGV[0]
unless project_name
    puts "Usage: ruby #{$PROGRAM_NAME} PROJECT_NAME"
    exit 1
end

generator = ProjectGenerator.new(project_name)
generator.create_project
end
  