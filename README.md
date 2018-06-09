# HrrRbNeCliSim

An application to simulate NEs that have CLI interface and is accessible with SSH.

# How to use

The `ne_cli_sim.rb` script is an good example.

To simulate a Nokia SR NE, define the NE with hostname, ip_address, and other parameters, and then run `ne_cli_sim`.

```ruby
require_relative './lib/server'

ne01 = {
  'model'      => 'nokia_sr',
  'hostname'   => 'ne01',
  'ip_address' => '127.0.0.1',
  'port'       => 50022,
  'username'   => 'user',
  'password'   => 'pass',
}

ne02 = {
  'model'      => 'nokia_sr',
  'hostname'   => 'ne02',
  'ip_address' => '127.0.0.1',
  'port'       => 50023,
  'username'   => 'user',
  'password'   => 'pass',
}

nes = [ne01, ne02]

ne_cli_sim nes
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

And host specific behavior is also customizable by writing `lib/<hostname>.rb` file. The host specific file is automatically loaded whenever a new connection from client is initiated.
