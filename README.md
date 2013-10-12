# PortageGT
[![Build Status](https://travis-ci.org/whatbox/PortageGT.png?branch=master)](https://travis-ci.org/whatbox/PortageGT)

## Overview
PortageGT (short for "Portage using Gentoo") is a replacement Package Provider for Puppet. It was written by [Whatbox Inc.](http://whatbox.ca/) to improve server management, and released as on Open Source project under the MIT, BSD & GPL licenses. Patches and bug reports are welcome, please see our [CLA](http://whatbox.ca/policies/contributions).

I will also warn you that this module is not completely compatible with the existing Portage Provider. Rather than making assumptions, this provider will throw errors in the event of ambiguity, preferring developer clarification over the possibility of performing an unintended action.


## Dependencies
The following packages are necessary for this module.
* `app-admin/puppet >= 3.0.0`
* `sys-apps/portage`
* `app-portage/eix`
* `dev-ruby/xml-simple`


## Environment
The following things are assumed:
* `/etc/portage/package.use` is a directory
* `/etc/portage/package.keywords` is a directory
* Both of the above are free for modification by puppet
* __WARNING:__ Folders contained within either of these will be automatically removed by this plugin


## Usage
Using PortageGT should be pretty familiar to anyone already using puppet on Gentoo, the only differences are in the added attributes that may be included in the manifests. The simplest case is the same as it is with existing puppet setups.

	package { "vnstat":
		ensure => "1.11-r2";
	}


### Categories
#### Name based

	package { "net-analyzer/vnstat":
		ensure => "1.11-r2";
	}

### Attribute based

	package { "vnstat":
		category => "net-analyzer",
		ensure => "1.11-r2";
	}

### Slots
#### Name based

	package { "dev-lang/php:5.4":
		ensure => latest;
	}

	package { "dev-lang/php:5.3":
		ensure => absent;
	}

#### Attribute based

	package { "dev-lang/python":
		slot   => "2.7",
		ensure => latest;
	}

	package { "dev-lang/python:3.1":
		slot   => "3.1",
		ensure => latest;
	}

### Keywords

	package { "sys-boot/grub":
		slot     => "2",
		keywords => "~amd64",
		ensure   => "2.00";
	}

### Custom Environment variables

	package { "dev-db/mongodb":
		keywords => "~amd64",
		environment => {
			"EPYTHON" => "python2.7",
		},
		ensure   => "2.2.2-r1";
	}

### Repository/Overlay
Specify the latest version of a specific overlay available on your systems, to ensure you don't accidentally build code from the wrong overlay.

	package { "www-servers/nginx":
		repository => "company-overlay",
		ensure => latest;
	}

### Use flags
#### String

	package { "www-servers/apache2":
		use    => "apache2_modules_alias apache2_modules_auth_basic",
		ensure => latest;
	}

### Array

	package { "www-servers/apache2":
		use    => [
			"apache2_modules_alias",
			"-ssl",
		],
		ensure => latest;
	}

### eselect
eselect is useful when selecting specific versions from between several slots

#### PHP

	eselect { "php-fpm":
		module => "php",
		submodule => "fpm",
		ensure => "php5.4";
	}

#### GCC

	eselect { "gcc":
		listcmd => "gcc-config -l",
		setcmd => "gcc-config",
		ensure => "x86_64-pc-linux-gnu-4.5.3";
	}

#### Ruby

	eselect { "ruby":
		ensure => "ruby19";
	}

#### Python

	eselect { "python":
		ensure => "python3.2";
	}

	eselect { "python2":
		module => "python",
		submodule => "--python2",
		ensure => "python2.7";
	}

	eselect { "python3":
		module => "python",
		submodule => "--python3",
		ensure => "python3.2";
	}

#### Profile

	eselect { "profile":
		ensure => "default/linux/amd64/13.0";
	}


#### kernel (/usr/src/linux)
	eselect { "kernel":
		ensure => "linux-3.7.0-hardened";
	}

#### locale

	eselect { "locale":
		ensure => "en_US.UTF-8";
	}

## Tuning behavior

Some configuration opetions can be found near the start of lib/puppet/provider/package/portagegt.rb that allow tuning of the modules behavior. The defaults cause explict use flag changes to recompile packages, and eix-sync to be run if it has been more than 48 hours since the last sync.


## Testing

To install dependencies necessary for running the tests use `bundle install`, tests can be run with `bundle exec rspec`. This project attempts to adhere to the [Ruby Stile Guide](https://github.com/bbatsov/ruby-style-guide/blob/master/README.md), you can verify your changes are in adhere to this guide using `bundle exec rubocop`.

**Note:** eix *must* be installed to test successfully on Gentoo, this is not necessary when running tests from other operating systems.

## Roadmap
* Remove package type overwrite ([Puppet #19561](http://projects.puppetlabs.com/issues/19561))
* More extensive unit testing
* Easier configuration of provider options


## Features Omitted
These are features we're not implementing at this time
* package mask
    * using puppet `ensure => :held`
* package unmask
* `RECOMPILE_USE_CHANGE` does not trigger a recompile if global use flags defined in `/etc/portage/make.conf` change.