#bitcoins 
#https://en.bitcoin.it/wiki/MtGox/API/HTTP/v2

use Irssi qw(signal_add print settings_add_str settings_get_str) ;
use strict;
use warnings;
use JSON;
use LWP::UserAgent;
use Data::Dumper;
 
settings_add_str('bitcoin', 'mtgox_api',    '');
settings_add_str('bitcoin', 'mtgox_secret', '');
signal_add('gold digger','mtgox');

my $buffer = 1800;
my $fetched = undef;
my $json = JSON->new();

#mtgox
my $mtgox = undef;
my $url   = 'https://data.mtgox.com/api/2/BTCUSD/money/ticker';
my $ua    = LWP::UserAgent->new( timeout => '15' );

#{{{ mtgox 
sub mtgox {
  my ($server, $chan) = @_;
  my $t = defined($mtgox) ? $fetched : 0;
  if (time - $t > $buffer) {
    $ua->agent(settings_get_str('myUserAgent'));
    my $req = $ua->get($url);
    my $r = eval { $json->utf8->decode($req->decoded_content) };
    return if $@;
    #print (CRAP Dumper($r));
    if ($r->{result} eq 'success' and not $@) {
      #print (CRAP "MTGOX");
      $mtgox  = '[MtGox] ';
      $mtgox .= 'sell: '     . $r->{data}{sell}{display_short} .' | ';
      $mtgox .= 'buy: '      . $r->{data}{buy}{display_short}  .' | ';
      $mtgox .= 'highest: '  . $r->{data}{high}{display_short} .' | ';
      $mtgox .= 'average: '  . $r->{data}{avg}{display_short};
      $fetched = time();
    } else { $mtgox = undef; }
  }
  sayit ($server, $chan, $mtgox) if (defined($mtgox));
  return;
}#}}}
sub sayit { my $s = shift; $s->command("MSG @_"); }
