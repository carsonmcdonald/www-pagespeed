package WWW::PageSpeed;

use LWP::UserAgent;
use URI::QueryParam;
use JSON;
use Data::Dumper;

use 5.010000;
use strict;
use warnings;

our $VERSION = '1.0';
our $API_URL = 'https://www.googleapis.com/pagespeedonline/v1/runPagespeed';

my %fields = (key => undef, local => "en_US", strategy => "desktop", rules => undef);

sub new 
{
  my $that = shift;
  my $class = ref($that) || $that;
  my $self = {};

  if(ref($that)) 
  {
    %$self = %$that;
  }
  else 
  {
    $self = { %fields, @_ };
  }

  die("API key required.") if (!$self->{key});
  die("Strategy is not valid.") if ($self->{strategy} ne 'mobile' && $self->{strategy} ne 'desktop');

  return bless($self, $class);
}

sub test
{
  my ($self, $args) = @_;
  my $target_url = $args->{url};
  my $rules = $args->{rules} || $self->{rules};

  die("Target URL required") if (!$target_url);
  die("Target URL is not valid, must match regex 'http(s)?://.*'") if ($target_url !~ /http(s)?:\/\/.*/);
  
  my $ua = LWP::UserAgent->new;
  $ua->agent("WWW-PageSpeed/$VERSION");

  my %params = ( key      => $self->{key},
                 url      => $target_url,
                 locale   => $self->{local},
                 strategy => $self->{strategy} );
 
  my $uri = URI->new($API_URL);
  $uri->query_form_hash( %params );

  if($rules)
  {
    foreach my $rulename (@$rules)
    {
      $uri->query_param_append('rule', $rulename);
    }
  }
  
  my $req = HTTP::Request->new(GET => $uri->canonical);

  my $res = $ua->request($req);

  my $json = JSON->new->allow_nonref;
  if ($res->is_success) 
  {
    return $json->decode( $res->content );
  }
  else 
  {
    my $psr = $json->decode( $res->content );
    die("API Error: $psr->{error}->{message} \n");
  }
}

1;
__END__

=head1 NAME

WWW::PageSpeed - Perl wrapper around the Google PageSpeed online API

=head1 SYNOPSIS

  use strict;
  use WWW::PageSpeed;

  my $key = "Your Google PageSpeed API Key";
  my $pagespeed = WWW::PageSpeed->new(key => $key);
  # You can also specify rules to use
  # my $pagespeed = WWW::PageSpeed->new(key => $key, rules => ['AvoidBadRequests', 'MinifyJavaScript']);
  # Or you can specify a strategy to use
  # my $pagespeed = WWW::PageSpeed->new(key => $key, strategy => 'mobile');

  my $psresults = $pagespeed->test({url => 'http://www.google.com/'});
  # You can also specify rules in the test request
  # my $psresults = $pagespeed->test({url => 'http://www.google.com/', rules => ['AvoidBadRequests', 'MinifyJavaScript']});

  for my $rulename (keys %{$psresults->{"formattedResults"}->{"ruleResults"}})
  {
    my $ruleresult = $psresults->{"formattedResults"}->{"ruleResults"}->{$rulename};

    print "Rule $rulename: Impact=$ruleresult->{'ruleImpact'} Score=$ruleresult->{'ruleScore'}\n";
  }

=head1 DESCRIPTION

WWW::PageSpeed - Perl wrapper around L<the Google PageSpeed online API|https://code.google.com/apis/pagespeedonline/>

Before using this wrapper read L<the getting started guide|https://code.google.com/apis/pagespeedonline/v1/getting_started.html>.

The API requires a key that you will find out about in the getting started guide. After you L<create an API key|https://code.google.com/apis/pagespeedonline/v1/getting_started.html#getaccount>
you can run the tests by sticking the key into the environment variable PAGESPEED_APIKEY.

Currently there are two supported strategies: 'desktop' or 'mobile'

The easiest way to get the list of supported rules is to run once without any rule
retrictions and print out the results.

Google supports a number of different languages, you can see the L<supported locals|https://code.google.com/speed/page-speed/docs/languages.html>
for a list.

=head1 SEE ALSO

L<the Google PageSpeed online API|https://code.google.com/apis/pagespeedonline/>

=head1 AUTHOR

Carson McDonald, <carson@ioncannon.net>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Carson McDonald

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
