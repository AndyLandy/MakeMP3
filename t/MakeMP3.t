#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1;

require("../MakeMP3");

my $seconds = &convert_time("02:30:00");

is($seconds, 150, "Convert time converts into time into decimal seconds");
