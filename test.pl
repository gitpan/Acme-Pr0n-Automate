# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use Acme::Pr0n::Automate qw(:categories);
ok(1); # If we made it this far, we're ok.

my $naughty = Acme::Pr0n::Automate->new(
	sources => [qw(Free6 Easypic)],
	categories => [BABES, LINGERIE, REDHEADS, PANTIES],
	db => "naughty_db",
);

$naughty->fetch();

my $quality_stuff = $naughty->search(
	from => time - 86400, 
	categories => [BABES, REDHEADS]
);

$quality_stuff->output(file => "naughty_db/today.html");

print STDERR "Your pr0n is available \@ naughty_db/today.html\n";
