#!/usr/bin/perl

use inc::Module::Install;

name		('Tie-Discovery');
author		('Autrijus Tang <autrijus@autrijus.org>');
abstract	('Lazily evaluated "discovery" hashes');
license		('perl');
version_from	('lib/Tie/Discovery.pm');

WriteAll( sign => 1 );
