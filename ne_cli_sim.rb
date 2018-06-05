# coding: utf-8
# vim: et ts=2 sw=2

require 'logger'

require_relative './lib/server'


logger = Logger.new STDOUT
logger.level = Logger::INFO

ne = {
  'hostname'   => 'ne01',
  'ip_address' => '127.0.0.1',
  'port'       => 50022,
  'username'   => 'user',
  'password'   => 'pass',
  'type'       => NokiaSr,
}

ne_cli_sim ne, logger