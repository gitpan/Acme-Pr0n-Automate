package Acme::Pr0n::Automate::Fetcher::Easypic;
use Acme::Pr0n::Automate qw(:categories);
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use HTML::Parser;
use strict;

our $URL = "http://www.easypic.com/main.html?bypass";

our %CATMAP = (
	TEENS => "teens",
	BABES => "babes",
	LINGERIE => "lingerie",
	PANTYHOSE => "pantyhose_-_stockings",
	PANTIES => "panties",
	REDHEADS => "redheads",
);

our %CATMAP_INV = map { $CATMAP{$_} => $_ } keys %CATMAP;

sub fetch {
	shift;
	my Acme::Pr0n::Automate $self = shift;

	my $ua = LWP::UserAgent->new("WHOP WHOP! It's the sound of da police!");
	my $req = HTTP::Request->new(GET => $URL);
	my $res = $ua->request($req);

	unless($res->is_success()) {
		print STDERR "$!\n";
		return undef;
	}

	unless(($res->last_modified || time) > $self->{db}->last_modified) {
		# We already have the data in the database, no need to update
		return;
	}

	$self->{db}->last_modified(($res->last_modified || time));

	my $content = $res->content();

	my $p = HTML::Parser->new(api_version => 3, start_h => [\&starttag, "self,tagname,attr"]);
	$p->{db} = $self->{db};
	$p->{lm} = $res->last_modified || time;	
	$p->{is_valid} = 0;
	$p->{result} = {};
	$p->parse($res->content());

	return 1;
}

sub starttag {
	my ($self, $tag, $attr) = @_;
	if(lc($tag) eq "a") {
		if(exists $attr->{href} && $self->{current}) {
			my $href = $attr->{href};
			return unless $href =~ qr!http://!;
			return if $href =~ /www\.easypic\.com/;
			return if $href =~ /www\.cash4galleries\.com/;
			return if $href =~ qr!http://[\.A-Za-z0-9\_\-]+/?$!;
			$self->{db}->store($self->{current}, $href, $self->{lm});
		} elsif(exists $attr->{name} && $attr->{name} ne "") {
			if(exists $CATMAP_INV{$attr->{name}}) {
				$self->{current} = $CATMAP_INV{$attr->{name}};
			} else {
				$self->{current} = 0;
			}
		}
	}
}

1;