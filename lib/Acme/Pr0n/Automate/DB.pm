#!/usr/bin/perl

package Acme::Pr0n::Automate::DB;
use DB_File;
use strict;

use fields qw(
	links
	updates
	categories
	dir
	timetables
	cat_map
);

sub new {
	my Acme::Pr0n::Automate::DB $self = fields::new(shift);
	my $dir = shift;
	my $categories = shift;

	$categories = undef unless(keys %$categories);
	$self->{cat_map} = $categories;

	$self->{dir} = $dir;

	unless(-e $dir && -d $dir) {
		mkdir($dir) || die $!;
	}

	unless(-e "$dir/categories" && -d "$dir/categories") {
		mkdir("$dir/categories") || die $!;
	}

	unless(-e "$dir/timetables" && -d "$dir/timetables") {
		mkdir("$dir/timetables") || die $!;
	}

	$self->{updates} = {};
	tie %{$self->{updates}}, 'DB_File', "$dir/updates.db", O_RDWR | O_CREAT, 0640, $DB_HASH or die $!;
	
	$self->{links} = {};
	tie %{$self->{links}}, 'DB_File', "$dir/links.db", O_RDWR | O_CREAT, 0650, $DB_HASH or die $!;

	$self->{categories} = {};

	return $self;
}

sub last_modified {
	my Acme::Pr0n::Automate::DB $self = shift;
	my $lm = shift;

	my ($eng) =	caller =~ /^Acme::Pr0n::Automate::Fetcher::(\w+)$/;

	$self->{updates}->{$eng} = $lm if(defined $lm && $lm);

	if(exists $self->{updates}->{$eng} && defined $self->{updates}->{$eng}) {
		return $self->{updates}->{$eng};
	}

	0;
}

sub open_category {
	my Acme::Pr0n::Automate::DB $self = shift;
	my $category = shift;
	return unless(defined $category && $category);
	return if(exists $self->{categories}->{$category});

	$self->{categories}->{$category} = {};
	tie %{$self->{categories}->{$category}}, 'DB_File', "$self->{dir}/categories/$category.db", O_RDWR | O_CREAT, 0640, $DB_HASH || die $!;

	1;
}

sub close_category {
	my Acme::Pr0n::Automate::DB $self = shift;
	my $category = shift;
	return unless(defined $category && $category);
	return unless(exists $self->{categories}->{$category});

	unless(tied %{$self->{categories}->{$category}}) {
		warn "$category is not tied, this should not be able to happen";
		return;
	}

	untie %{$self->{categories}->{$category}};

	1;
}

sub open_timetable {
	my Acme::Pr0n::Automate::DB $self = shift;
	my $time = shift;
	return unless(defined $time && $time);
	return if(exists $self->{timetables}->{$time});

	$self->{timetables}->{$time} = {};
	tie %{$self->{timetables}->{$time}}, 'DB_File', "$self->{dir}/timetables/$time.db", O_RDWR | O_CREAT, 0640, $DB_HASH || die $!;

	1;
}

sub close_timetable {
	my Acme::Pr0n::Automate::DB $self = shift;
	my $time = shift;
	return unless(defined $time && $time);
	return unless(exists $self->{timetables}->{$time});
	unless(tied %{$self->{timetables}->{$time}}) {
		warn "$time is not tied, this should not be able to happen";
		return;
	}
	
	untie %{$self->{timetables}->{$time}};

	1;
}

sub store {
	my Acme::Pr0n::Automate::DB $self = shift;
	my $category = shift;
	my $link = shift;
	my $time = shift;
	my $description = shift;

	if(defined $category && defined $self->{cat_map}) {
		return unless exists $self->{cat_map}->{$category};
	}

	# Return if the link is in the database
	return if exists $self->{links}->{$link};

	# Store link in links with category
	$self->{links}->{$link} = $description;
	
	# Store link in category with time
	$self->open_category($category);
	$self->{categories}->{$category}->{$link} = $time;

	# Store link in timetable
	$self->open_timetable($time);
	$self->{timetables}->{$time}->{$link} = $category;

	1;
}

use Data::Dumper qw(Dumper);

sub search {
	my Acme::Pr0n::Automate::DB $self = shift;
	die "Invalid number of arguments" if @_ & 1;

	my %attr = @_;
	my $result = {};

	if(exists $attr{from}) {
		# Open timetable directory and scan
		opendir(TIMETABLES, "$self->{dir}/timetables") || die $!;
		my @files = map { substr($_, 0, -3) } grep { /^(\d+)\.db$/ && $1 > $attr{from} } readdir(TIMETABLES);
		closedir(TIMETABLES);

		my $match_cat = undef;
		if(exists $attr{categories} && ref $attr{categories} eq "ARRAY" && @{$attr{categories}}) {
			$match_cat = "^" . join("|", @{$attr{categories}}) . "\$";
		}

		foreach my $t (@files) {
			$self->open_timetable($t);

			my $i = 0;

			LINKS: foreach(keys %{$self->{timetables}->{$t}}) {
				my $val = $self->{timetables}->{$t}->{$_};

				if(defined $match_cat) {
					next LINKS unless $val =~ /$match_cat/;
				}

				my $category = $val;

				$result->{$category} = [] unless(ref $result->{$category} eq "ARRAY");
				push @{$result->{$category}}, { link => $_, time => $t, desc => $self->{links}->{$_} };
				
			} continue { $i++ }

			$self->close_timetable($t);
		}
	} elsif(exists $attr{categories}) {
	} 

	return bless $result, 'Acme::Pr0n::Automate::View';
}

1;