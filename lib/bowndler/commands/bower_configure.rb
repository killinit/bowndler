require 'pathname'
require 'erb'
require 'json'

module Bowndler
  module Commands
    class BowerConfigure

      class GemAwareTemplate
        def gem_path(name)
          Bundler.rubygems.find_name(name).first.full_gem_path
        end
      end

      attr_reader :template, :output_path
      private :template, :output_path

      def initialize(template_path)
        template_path = Pathname.new(template_path)
        @output_path = template_path.dirname.join('bower.json')

        erb = ERB.new(IO.read(template_path))
        erb.filename = template_path.to_s
        @template = erb.def_class(GemAwareTemplate, 'render()').new
      end

      def call
        bower_config = JSON.parse(template.render)
        bower_config = {:__warning__ => [
          " ************************************************************************** ",
          " *                                                                        * ",
          " * WARNING!                                                               * ",
          " * This file is generated. ANY CHANGES YOU MAKE MAY BE OVERWRITTEN.       * ",
          " *                                                                        * ",
          " * To add/edit bower dependencies, please edit bower.json.erb, and run    * ",
          " * `bowndler bower_configure` to regenerate this file.                    * ",
          " *                                                                        * ",
          " ************************************************************************** ",
        ]}.merge(bower_config)

        bower_json = JSON.pretty_generate(bower_config)
        File.open(output_path, 'w') do |file|
          file.write(bower_json)
        end
      end
    end
  end
end
