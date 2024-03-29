package Acme::Pr0n::Automate::Fetcher::Easypic;
use Acme::Pr0n::Automate qw(:categories);
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use HTML::Parser;
use strict;

our $URL = "http://www.easypic.com/main.html?bypass";

our %CATMAP = (
	WEBCAMS => "webcams",			TEENS => "teens",
	ASIAN_TEENS => "asian_teens",	CHEERLEADERS => "cheerleaders",
	LOLITA => "lolita_links",		AMATEURS => "amateurs",
	HOUSEWIVES => "housewives",		BATH_SHOWER_POOL => "bath-_shower_-_pool",
	BABES => "babes",				BIKINI => "bikini_babes",
	EBONY => "ebony_babes",			LATINA => "latina_babes", 
	ASIANS => "asians",				REDHEADS => "redheads",
	LINGERIE => "lingerie",			HARDCORE => "hardcore",
	GROUPS => "groups",				OUTSIDE => "outside_sex",
	MASTURBATE => "masturbate",		TOYS => "toys",
	BLOWJOBS => "blowjobs",			CUMSHOTS => "cumshots", 
	CLOSEUPS => "closeups",			INTERRACIAL => "interracial",
	ANAL => "anal",					ASSES => "asses", 
	BIG_GIRLS => "big_girls",		SMALL_TITS => "small_tits",
	BIG_TITS => "big_tits",			NIPPLES => "nipples", 
	OLDER_BABES => "older_babes",	LESBIANS => "lesbians",
	PUSSY => "pussy",				SHAVED => "shaved",
	HAIRY_PUSSY => "hairy_pussy",	PORNSTARS => "pornstars", 
	CELEBRITIES => "celebrities",	WORKOUT => "naked_workout",
	VINTAGE => "vintage",			UNIFORMS => "uniforms",
	PANTIES => "panties",			PANTYHOSE => "pantyhose_-_stockings",
	PIERCINGS => "piercings_-_tattoos",
	FOOT_FETISH => "foot_fetish", 	PREGNANT => "pregnant",
	FISTING => "fisting",			PEE => "pee",
	VOYEURISM => "voyeurism",		UPSKIRTS => "upskirts",
	SPANKING => "spanking",			BONDAGE => "sm_-_bondage",
	BIZARRE => "bizarre",			NUDISTS => "nudists",
	ANIME => "anime",				NUDE_MALES => "nude_males", 
	BISEXUAL => "bisexual",			GAY => "gay", 
	SHEMALE => "shemale",
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

	my $lm = $self->{fetch_time};

	unless(($res->last_modified || $lm) > $self->{db}->last_modified) {
		# We already have the data in the database, no need to update
		return;
	}

	$self->{db}->last_modified(($res->last_modified || $lm));

	my $p = HTML::Parser->new(api_version => 3, start_h => [\&starttag, "self,tagname,attr"]);
	$p->{db} = $self->{db};
	$p->{lm} = $res->last_modified || $lm;	
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
			return unless $href =~ qr!^http://!;
			return if $href =~ /www\.easypic\.com/;
			return if $href =~ /www\.cash4galleries\.com/;
			return if $href =~ qr!http://[\.A-Za-z0-9\_\-]+/?$!;
			$self->{db}->store($self->{current}, $href, $self->{lm}, "");
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