use 5.010000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'WWW::PageSpeed',
    VERSION_FROM      => 'lib/WWW/PageSpeed.pm',
    PREREQ_PM => {
        'JSON' => '0',
        'LWP' => '0',
        'URI' => '0',
        'URI::QueryParam' => '0',
    },
    META_MERGE      => {
      resources => {
          license     => 'http://dev.perl.org/licenses/',
          bugtracker  => 'https://github.com/carsonmcdonald/www-pagespeed/issues',
          repository  => 'https://github.com/carsonmcdonald/www-pagespeed',
      },
    },
    ($] >= 5.005 ? 
      (ABSTRACT_FROM  => 'lib/WWW/PageSpeed.pm',
       AUTHOR         => 'Carson McDonald <carson@ioncannon.net>') : ()),
);
