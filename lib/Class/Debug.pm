package Class::Debug;

use strict;
use warnings;

use Carp;
use Config::Abstraction 0.20;
use Log::Abstraction 0.11;

=head1 NAME

Class::Debug - Add Runtime Debugging to a Class

=head1 VERSION

0.02

=cut

our $VERSION = 0.02;

=head1 SYNOPSIS

The C<Class::Debug> module is a lightweight utility designed to inject runtime debugging capabilities into other classes,
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

=head2 CHANGING BEHAVIOUR AT RUN TIME

=head3 USING A CONFIGURATION FILE

To control debug behavior at runtime, C<Class::Debug> supports loading settings from a configuration file via L<Config::Abstraction>.

A minimal example of a config file (C<~/.conf/local.conf>) might look like:

   [My::Module]

   logger.file = /var/log/mymodule.log

The C<setup()> function will read this file,
overlay it onto your default parameters,
and initialize the logger accordingly.

If the file is not readable and no config_dirs are provided,
the module will throw an error.

This mechanism allows dynamic tuning of logging behavior (or other parameters you expose) without modifying code.

More details to be written.

=head3 USING ENVIRONMENT VARIABLES

C<Class::Debug> also supports runtime configuration via environment variables,
without requiring a configuration file.

Environment variables are read automatically when you use the C<setup()> function,
thanks to its integration with L<Config::Abstraction>.
These variables should be prefixed with your class name, followed by a double colon.

For example, to enable syslog logging for your C<My::Module> class,
you could set:

    export My::Module::logger.file=/var/log/mymodule.log

This would be equivalent to passing the following in your constructor:

     My::Module->new(logger => Log::Abstraction->new({ file => '/var/log/mymodule.log' });

All environment variables are read and merged into the default parameters under the section named after your class.
This allows centralized and temporary control of debug settings (e.g., for production diagnostics or ad hoc testing) without modifying code or files.

Note that environment variable settings take effect regardless of whether a configuration file is used,
and are applied during the call to C<setup()>.

More details to be written.

=head1 SUBROUTINES/METHODS

=head2 setup

Configure your class for runtime debugging.

Takes two arguments:

=over 4

=item * C<class>

=item * C<params>

A hashref containing default parameters to be used in the constructor.

=back

Returns the new values for the constructor.

Now you can set up a configuration file and environment variables to debug your module.

=cut

sub setup
{
	my $class = shift;
	my $params = shift;

	# Load the configuration from a config file, if provided
	if(exists($params->{'config_file'})) {
		# my $config = YAML::XS::LoadFile($params->{'config_file'});
		my $config_dirs = $params->{'config_dirs'};
		if((!$config_dirs) && (!-r $params->{'config_file'})) {
			croak("$class: ", $params->{'config_file'}, ': File not readable');
		}

		if(my $config = Config::Abstraction->new(config_dirs => $config_dirs, config_file => $params->{'config_file'}, env_prefix => "${class}::")) {
			$params = $config->merge_defaults(defaults => $params, section => $class);
		} else {
			croak("$class: Can't load configuration from ", $params->{'config_file'});
		}
	} elsif(my $config = Config::Abstraction->new(env_prefix => "${class}::")) {
		$params = $config->merge_defaults(defaults => $params, section => $class);
	}

	# Load the default logger, which may have been defined in the config file or passed in
	if(my $logger = $params->{'logger'}) {
		if((ref($logger) eq 'HASH') && $logger->{'syslog'}) {
			$params->{'logger'} = Log::Abstraction->new(carp_on_warn => 1, syslog => $logger->{'syslog'});
		} else {
			$params->{'logger'} = Log::Abstraction->new(carp_on_warn => 1, logger => $logger);
		}
	} else {
		$params->{'logger'} = Log::Abstraction->new(carp_on_warn => 1);
	}

	return $params;
}

=head1 SEE ALSO

=over 4

=item * L<Config::Abstraction>

=item * L<Log::Abstraction>

=back

=head1 SUPPORT

This module is provided as-is without any warranty.

Please report any bugs or feature requests to C<bug-class-debug at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class-Debug>.
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

You can find documentation for this module with the perldoc command.

    perldoc Class::Debug

=head1 LICENSE AND COPYRIGHT

Copyright 2025 Nigel Horne.

Usage is subject to licence terms.

The licence terms of this software are as follows:

=over 4

=item * Personal single user, single computer use: GPL2

=item * All other users (including Commercial, Charity, Educational, Government)
  must apply in writing for a licence for use from Nigel Horne at the
  above e-mail.

=back

=cut

1;
