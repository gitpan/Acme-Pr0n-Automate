# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use Acme::Pr0n::Automate qw(:categories);
use Data::Dumper qw(Dumper);
ok(1); # If we made it this far, we're ok.

my $naughty = Acme::Pr0n::Automate->new(
	sources => [qw(Easypic)],
	categories => [BABES, LINGERIE, REDHEADS, PANTIES],
	db => "/home/naugthy/",
);

$naughty->fetch();

my $quality_stuff = $naughty->search(from => time() - 86400, categories => [LINGERIE]);

$quality_stuff->output(file => "today.html");

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.