$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "lib")))

ENV['RACK_ENV'] = 'production'

require 'factervision'

require 'logger'
class ::Logger; alias_method :write, :<<; end

logger = Logger.new('log/app.log')
use Rack::CommonLogger, logger

use Rack::ShowExceptions

run FacterVision::Application.new
