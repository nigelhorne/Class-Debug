# NAME

Class::Debug - Add Runtime Debugging to a Class

# VERSION

0.02

# SYNOPSIS

The `Class::Debug` module is a lightweight utility designed to inject runtime debugging capabilities into other classes,
primarily by layering configuration and logging support.

Add this to your constructor:

    package My::Module;

    use Class::Debug;
    use Params::Get;

    sub new {
         my $class = shift;
         my $params = Params::Get(undef, \@_);

         $params = Class::Debug::setup($class, $params);

         return bless $params, $class;
     }

Throughout your class, add code such as:

    $self->{'logger'}->debug(ref($self), ': ', __LINE__, ' doing something I want to log');

## CHANGING BEHAVIOUR AT RUN TIME

### USING A CONFIGURATION FILE

To control debug behavior at runtime, `Class::Debug` supports loading settings from a configuration file via [Config::Abstraction](https://metacpan.org/pod/Config%3A%3AAbstraction).

A minimal example of a config file (`~/.conf/local.conf`) might look like:

    [My::Module]

    logger.file = /var/log/mymodule.log

The `setup()` function will read this file,
overlay it onto your default parameters,
and initialize the logger accordingly.

If the file is not readable and no config\_dirs are provided,
the module will throw an error.

This mechanism allows dynamic tuning of logging behavior (or other parameters you expose) without modifying code.

More details to be written.

### USING ENVIRONMENT VARIABLES

`Class::Debug` also supports runtime configuration via environment variables,
without requiring a configuration file.

Environment variables are read automatically when you use the `setup()` function,
thanks to its integration with [Config::Abstraction](https://metacpan.org/pod/Config%3A%3AAbstraction).
These variables should be prefixed with your class name, followed by a double colon.

For example, to enable syslog logging for your `My::Module` class,
you could set:

    export My::Module::logger.file=/var/log/mymodule.log

This would be equivalent to passing the following in your constructor:

     My::Module->new(logger => Log::Abstraction->new({ file => '/var/log/mymodule.log' });

All environment variables are read and merged into the default parameters under the section named after your class.
This allows centralized and temporary control of debug settings (e.g., for production diagnostics or ad hoc testing) without modifying code or files.

Note that environment variable settings take effect regardless of whether a configuration file is used,
and are applied during the call to `setup()`.

More details to be written.

# SUBROUTINES/METHODS

## setup

Configure your class for runtime debugging.

Takes two arguments:

- `class`
- `params`

    A hashref containing default parameters to be used in the constructor.

Returns the new values for the constructor.

Now you can set up a configuration file and environment variables to debug your module.

# SEE ALSO

- [Config::Abstraction](https://metacpan.org/pod/Config%3A%3AAbstraction)
- [Log::Abstraction](https://metacpan.org/pod/Log%3A%3AAbstraction)

# SUPPORT

This module is provided as-is without any warranty.

Please report any bugs or feature requests to `bug-class-debug at rt.cpan.org`,
or through the web interface at
[http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class-Debug](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class-Debug).
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

You can find documentation for this module with the perldoc command.

    perldoc Class::Debug

# LICENSE AND COPYRIGHT

Copyright 2025 Nigel Horne.

Usage is subject to licence terms.

The licence terms of this software are as follows:

- Personal single user, single computer use: GPL2
- All other users (including Commercial, Charity, Educational, Government)
  must apply in writing for a licence for use from Nigel Horne at the
  above e-mail.
