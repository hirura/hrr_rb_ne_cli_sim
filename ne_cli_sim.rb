# coding: utf-8
# vim: et ts=2 sw=2

require 'logger'

require_relative './lib/server'


logger = Logger.new STDOUT
logger.level = Logger::INFO

nes = [
  {
    'model'      => 'nokia_sr',
    'hostname'   => 'ne01',
    'ip_address' => '127.0.0.1',
    'port'       => 50022,
    'username'   => 'user',
    'password'   => 'pass',
  },
  {
    'model'      => 'nokia_sr',
    'hostname'   => 'ne02',
    'ip_address' => '127.0.0.1',
    'port'       => 50023,
    'username'   => 'user',
    'password'   => 'pass',
  }
]

ne_cli_sim nes, logger
