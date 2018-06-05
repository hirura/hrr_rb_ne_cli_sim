# HrrRbNeCliSim

An application to simulate NEs that have CLI interface and is accessible with SSH.

# How to use

The `ne_cli_sim.rb` script is an good example.

To simulate a Nokia SR NE, define the NE with hostname, ip_address, and other parameters, and then run `ne_cli_sim`.

```ruby
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
```

Then you can login to the NE like following.

```
$ ssh 127.0.0.1 -p 50022 -l user
Password: pass
A:ne01#
```

The simulator support only returning pre-defined output based on an input. There is no network functionality.

```
A:ne01# customer 1 create
A:ne01>cust# exit all
A:ne01# vpls 1 customer 1 create
A:ne01>vpls# exit all
A:ne01# logout
Connection to 127.0.0.1 closed.
$
```

The input and output combinations are defined in `lib/nokia_sr.rb`. It is possible to add required command and its response.
