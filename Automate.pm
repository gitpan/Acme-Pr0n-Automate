package Acme::Pr0n::Automate;

use 5.006;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);
use Acme::Pr0n::Automate::DB;
use Acme::Pr0n::Automate::View;
our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Acme::Pr0n::Automate ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

our %EXPORT_TAGS = ( 
	'all' => [ qw(
				  ) ], 
	'categories' => [ qw(
		WEBCAMS TEENS ASIAN_TEENS CHEERLEADERS LOLITA AMATEURS
		HOUSEWIVES BATH_SHOWER_POOL BABES BIKINI EBONY LATINA
		ASIANS REDHEADS LINGERIE HARDCORE GROUPS OUTSIDE 
		MASTURBATE TOYS BLOWJOBS CUMSHOTS CLOSEUPS INTERRACIAL
		ANAL ASSES BIG_GIRLS SMALL_TITS BIG_TITS NIPPLES
		OLDER_BABES LESBIANS PUSSY SHAVED HAIRY_PUSSY PORNSTARS
		CELEBRITIES WORKOUT VINTAGE UNIFORMS PANTIES PANTYHOSE
		PIERCINGS FOOT_FETISH PREGNANT FISTING PEE VOYEURISM
		UPSKIRTS SPANKING BONDAGE BIZARRE NUDISTS ANIME
		NUDE_MALES BISEXUAL GAY SHEMALE
	) ],
);

our @EXPORT_OK = ( @{$EXPORT_TAGS{'all'}}, @{$EXPORT_TAGS{'categories'}} );

our @EXPORT = qw(
	
);

our $VERSION = '0.03';


# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.


#use constant 

use constant WEBCAMS => "WEBCAMS";
use constant TEENS => "TEENS";
use constant ASIAN_TEENS => "ASIAN_TEENS";
use constant CHEERLEADERS => "CHEERLEADERS";
use constant LOLITA => "LOLITA";
use constant AMATEURS => "AMATEURS";
use constant HOUSEWIVES => "HOUSEWIVES";
use constant BATH_SHOWER_POOL => "BATH_SHOWER_POOL";
use constant BABES => "BABES";
use constant BIKINI => "BIKINI";
use constant EBONY => "EBONY";
use constant LATINA => "LATINA";
use constant ASIANS => "ASIANS";
use constant REDHEADS => "REDHEADS";
use constant LINGERIE => "LINGERIE";
use constant HARDCORE => "HARDCORE";
use constant GROUPS => "GROUPS";
use constant OUTSIDE => "OUTSIDE";
use constant MASTURBATE => "MASTURBATE";
use constant TOYS => "TOYS";
use constant BLOWJOBS => "BLOWJOBS";
use constant CUMSHOTS => "CUMSHOTS";
use constant CLOSEUPS => "CLOSEUPS";
use constant INTERRACIAL => "INTERRACIAL";
use constant ANAL => "ANAL";
use constant ASSES => "ASSES";
use constant BIG_GIRLS => "BIG_GIRLS";
use constant SMALL_TITS => "SMALL_TITS";
use constant BIG_TITS => "BIG_TITS";
use constant NIPPLES => "NIPPLES";
use constant OLDER_BABES => "OLDER_BABES";
use constant LESBIANS => "LESBIANS";
use constant PUSSY => "PUSSY";
use constant SHAVED => "SHAVED";
use constant HAIRY_PUSSY => "HAIRY_PUSSY";
use constant PORNSTARS => "PORNSTARS";
use constant CELEBRITIES => "CELEBRITIES";
use constant WORKOUT => "WORKOUT";
use constant VINTAGE => "VINTAGE";
use constant UNIFORMS => "UNIFORMS";
use constant PANTIES => "PANTIES";
use constant PANTYHOSE => "PANTYHOSE";
use constant PIERCINGS => "PIERCINGS";
use constant FOOT_FETISH => "FOOT_FETISH";
use constant PREGNANT => "PREGNANT";
use constant FISTING => "FISTING";
use constant PEE => "PEE";
use constant VOYEURISM => "VOYEURISM";
use constant UPSKIRTS => "UPSKIRTS";
use constant SPANKING => "SPANKING";
use constant BONDAGE => "BONDAGE";
use constant BIZARRE => "BIZARRE";
use constant NUDISTS => "NUDISTS";
use constant ANIME => "ANIME";
use constant NUDE_MALES => "NUDE_MALES";
use constant BISEXUAL => "BISEXUAL";
use constant GAY => "GAY";
use constant SHEMALE => "SHEMALE";

our %FETCH_ENGINE;

BEGIN {
	my ($path) = __FILE__ =~ /^(.*)\.pm$/;

	
	opendir(FETCHERS, "$path/Fetcher");
	my @dirs = grep { /\.pm$/ } readdir(FETCHERS);
	closedir(FETCHERS);
	
	foreach(@dirs) {
		eval {
			require "$path/Fetcher/$_";
			s/\.pm$//;
			my $pkg = "Acme::Pr0n::Automate::Fetcher::$_";
			if(UNIVERSAL::can($pkg, "fetch")) {
				$FETCH_ENGINE{lc($_)} = $pkg;
			} else {
				die "No fetch method";
			}
		};

		if($@) {
			print STDERR "Unable to load fetcher '$_'\n";
			print STDERR "Because of: '$@'\n";
		}
	}
}

use fields qw(
	categories
	sources
	db
);

sub new {
	# Get package name
	my Acme::Pr0n::Automate $self = fields::new(shift);

	# Get arguments
	my %attr = @_;

	# Check for sites
	die "Missing argument 'source'" unless exists $attr{sources};
	die "Missing argument 'db'" unless exists $attr{db};

	# Fetch sources
	$self->{sources} = {};
	if(ref $attr{sources} eq 'ARRAY') {
		%{$self->{sources}} = map { lc($_) => 1 } @{$attr{sources}};
	} else {
		$self->{sources}->{lc($attr{sources})} = 1;
	}

	foreach(keys %{$self->{sources}}) {
		die "Invalid source" unless exists $FETCH_ENGINE{$_};
	}

	# Create a database object
	$self->{db} = Acme::Pr0n::Automate::DB->new($attr{db});

	return $self;
}

sub fetch {
	my Acme::Pr0n::Automate $self = shift;

	# Loop thru fetch engines, and call fetch
	my $i = 1;
	foreach(keys %FETCH_ENGINE) {
		$FETCH_ENGINE{$_}->fetch($self);
	}
}

sub search {
	my Acme::Pr0n::Automate $self = shift;

	return $self->{db}->search(@_);
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Acme::Pr0n::Automate - All your pr0n are belongs to us

=head1 SYNOPSIS

  PARENTAL ADVISORY - EXPLICIT CONTENT
  ------------------------------------

  my $naughty = Acme::Pr0n::Automate->new(
	sources => [qw(Easypic)],
	categories => [BABES, LINGERIE, REDHEADS, PANTIES],
	db => "/path/to/store/pr0n/database",
	);

  $naughty->fetch();

  my $quality_stuff = $naughty->search(
	from => time() - 86400, 
	categories => [LINGERIE]
  );

  $quality_stuff->output(file => "today.html");

=head1 DESCRIPTION

Acme::Pr0n::Automates automates your pr0n desires

=head2 EXPORT

None by default.

:categories
Get all categories, check Automate.pm for details

=head1 AUTHOR

The pimp daddy <lt>claesjac@cpan.org<gt>

=head1 SEE ALSO

L<perl>.
L<sex> || L<Sex>.
UPC after midnight.

=cut
