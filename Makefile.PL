use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Acme::Pr0n::Automate',
    'VERSION_FROM'	=> 'Automate.pm', # finds $VERSION
    'PREREQ_PM'		=> { 
		"HTML::Parser" => 3.25,
		"LWP::UserAgent" => 1.77,
		"DB_File" => 1.73
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Automate.pm', # retrieve abstract from module
       AUTHOR     => 'A. U. Thor <a.u.thor@a.galaxy.far.far.away>') : ()),
);
