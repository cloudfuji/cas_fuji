require File.join(File.dirname(__FILE__), 'lib', 'cas_fuji.rb')

CasFuji::App..set({:environment => ENV['RACK_ENV'] || :development,
                    :port       => ARGV.first || 8080,
                    :sessions   => true,
                    :logging    => true})


run CasFuji::App
