#!/usr/bin/perl

package Acme::Pr0n::Automate::View::HTML;
use IO::File;
use strict;

sub start {
	my Acme::Pr0n::Automate::View::HTML $self = shift;
	my $file = shift;
	my $io = IO::File->new($file, "w") || die $!;

	print $io "<html>\n<head>\n<title>Pr0n</title>\n</head>\n<body bgcolor=\"#ffffff\">";

	$self->{_io} = $io;

	1;
}

sub write_category {
	my Acme::Pr0n::Automate::View::HTML $self = shift;
	my $name = shift;
	my $category = shift;

	return unless(ref $category eq "ARRAY");

	my @links = sort { $b->{time} <=> $a->{time} } @$category;

	my $io = $self->{_io};

	print $io "<br><font size=\"+1\"><b>$name</b></font><br><br>" if $name;
	print $io "<a href=\"$_->{link}\" target=\"_new\">$_->{link}</a><br>" foreach(@links);

	1;
}

sub stop {
	my Acme::Pr0n::Automate::View::HTML $self = shift;
	my $io = $self->{_io};

	print $io "</body></html>";
	$io->close();

	delete $self->{_io};
	1;
}

package Acme::Pr0n::Automate::View;
use strict;

sub output {
	my Acme::Pr0n::Automate::View $self = shift;
	my %attr = @_;

	if(exists $attr{file}) {
		my ($type) = $attr{file} =~ /\.(\w+)$/;
		$type = uc($type);

		die "Unsupported format" if($type !~ /^HTML$/);

		$self = bless $self, "Acme::Pr0n::Automate::View::$type";

		$self->start($attr{file});

		foreach(sort keys %$self) {
			next if /^_/;
			$self->write_category($_, $self->{$_});
		}

		$self->stop($attr{file});
	}
}

1;