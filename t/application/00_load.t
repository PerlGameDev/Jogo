use strict;
use warnings;
use Test::Most 'bail';

BEGIN {
	my @modules = qw /
		Jogo
		/;
	plan tests => scalar @modules;

	use_ok $_ foreach @modules;
}
