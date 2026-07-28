module Hvor
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a Hvor initializer and prints setup instructions."

      def copy_initializer
        template "initializer.rb", "config/initializers/hvor.rb"
      end

      def show_readme
        say ""
        say "Hvor is installed. Next steps:", :green
        say "  1. Mount the engine, e.g. in config/routes.rb:"
        say '       mount Hvor::Engine => "/hvor"'
        say "  2. Install and run its migration:"
        say "       bin/rails hvor:install:migrations"
        say "       bin/rails db:migrate"
        say "  3. Set an IP2Location LITE token in config/initializers/hvor.rb"
        say "     (or the IP2LOCATION_TOKEN env var), then enqueue"
        say "     Hvor::ImportIpRangesJob to populate Hvor::IPRange."
        say ""
      end
    end
  end
end
