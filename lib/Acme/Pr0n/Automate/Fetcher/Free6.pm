package Acme::Pr0n::Automate::Fetcher::Free6;
use Acme::Pr0n::Automate qw(:categories);
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use HTML::Parser;
use strict;

our %CATMAP = (
	AMATEURS => 2,
	ANAL => 29,
	ASIANS => 4,
	ASSES => 43,
	BABES => 5,				
	BIG_GIRLS => 24,		
	BIKINI => 36,
	BISEXUAL => 49,			
	BIZARRE => 10,			
	BONDAGE => 7,
	CELEBRITIES => 38,	
	EBONY => 25,			
	GAY => 16, 
	GROUPS => 44,				
	HARDCORE => 13,
	LATINA => 14, 
	LESBIANS => 15,
	LINGERIE => 45,			
	OLDER_BABES => 28,	
	PORNSTARS => 41, 
	PREGNANT => 12,
	REDHEADS => 19,
	SHAVED => 18,
	SHEMALE => 20,
	TEENS => 27,
	TOYS => 9,
	UPSKIRTS => 42,
	VOYEURISM => 52,		
);

our $BASE_URL = "http://www.free6.com/category/category_en.php?cat=";

sub fetch {
	shift;
	my Acme::Pr0n::Automate $self = shift;

	my $ua = LWP::UserAgent->new("WHOP WHOP! It's the sound of da police!");

	# Free6 doesn't send last-modified
	my $lm = $self->{fetch_time};
	$self->{db}->last_modified($lm);

	# Create a parser
	my $p = HTML::Parser->new(api_version => 3, start_h => [\&start, "self,tagname,attr"], text_h => [\&text, "self,dtext"]);
	$p->{db} = $self->{db};
	$p->{lm} = $lm;

	# Go over each category
	foreach(keys %{$self->{db}->{cat_map}}) {
		my $URL = $BASE_URL . $CATMAP{$_};

		my $req = HTTP::Request->new(GET => $URL);
		my $res = $ua->request($req);

		unless($res->is_success()) {
			print STDERR "$!\n";
			next;
		}

		$p->{in_link} = 0;
		$p->{href} = "";
		$p->{act_td} = 0;
		$p->{next_text} = 0;
		$p->{current} = $_;

		$p->parse($res->content());
	}

	return 1;
}

sub start {
		my ($self, $tag, $attr) = @_;

		if(lc($tag) eq "a") {
			my $href = "$attr->{href}";
			if($href =~ /\/report\/report_dk.php\?/) {
				$self->{act_td} = 1;
				return;
			}

			return unless($href =~ /^\/gallery\.php\?url\=(.*\.html)\&/);
			$href = "http://$1";
			$self->{in_link} = 1;
			$self->{href} = $href;
			$self->{act_td} = 0;
			$self->{next_text} = 0;
		} elsif($tag eq 'td') {
			$self->{next_text} = 1 if($self->{act_td});
		}
}

sub text {
	my ($self, $text) = @_;
	return unless($self->{in_link} && $self->{next_text});
	$text =~ s/^\W*//;

	# Insert in database here
	$self->{db}->store($self->{current}, $self->{href}, $self->{lm}, $text);

	# Clear temporary parser stuff
	$self->{in_link} = 0;
	$self->{href} = "";
	$self->{act_td} = 0;
	$self->{next_text} = 0;
}

1;
