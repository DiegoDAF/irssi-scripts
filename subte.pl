#estado de subte 

use Irssi qw(signal_add print settings_add_str settings_get_str) ;
use strict;
use warnings;
use LWP::UserAgent;
use Data::Dumper;
use XML::Simple;
 
settings_add_str('bot config', 'subte_agent', '');
settings_add_str('bot config', 'subte_url',   '');

signal_add('hay subte', 'check_subte');

my $buffered_for  = 480;    #secs. ~8mins
my $last_fetched  = 0;
my %subtes;

my $xs = XML::Simple->new();
my $ua  = LWP::UserAgent->new( timeout  => 10,
                               agent    => settings_get_str('subte_agent')
                             );
#{{{ 
sub check_subte {
  my ($server, $chan, $linea) = @_;
  fetch_status() if (time - $last_fetched > $buffered_for);
  my $output = "status de la linea $linea: [$subtes{$linea}->{status}]";
  if ($subtes{$linea}->{freq} > 0) {
    $output .= ' - frecuencia: ' . int($subtes{$linea}->{freq} / 60) . ' mins';
  }
  sayit ($server, $chan, $output);
  return;
}#}}}

sub fetch_status {
  my $raw_result = $ua->get(settings_get_str('subte_url'))->content();
  #print (CRAP Dumper($raw_result));
  my $parsedxml_ref = $xs->XMLin($raw_result);
  %subtes = map { chop($_->{nombre}) =>
                    {
                      'status'  => ref $_->{'estado'}     eq 'HASH' ? 'OK'
                      : $_->{'estado'},
                      'freq'    => ref $_->{'frecuencia'} eq 'HASH' ? '0' 
                      : $_->{'frecuencia'}
                    }
                } @{ $parsedxml_ref->{'Linea'} };
  $last_fetched = time();
}
sub sayit { my $s = shift; $s->command("MSG @_"); }
