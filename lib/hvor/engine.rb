module Hvor
  class Engine < ::Rails::Engine
    isolate_namespace Hvor

    # "ip_range.rb" would otherwise camelize to "IpRange" -- register the
    # acronym so Zeitwerk resolves it to the IPRange model.
    initializer "hvor.inflections", before: :set_autoload_paths do
      Rails.autoloaders.each do |autoloader|
        autoloader.inflector.inflect("ip_range" => "IPRange")
      end
    end
  end
end
