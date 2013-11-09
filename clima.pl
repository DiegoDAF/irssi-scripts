#clima.pl
#documentation http://www.wunderground.com/weather/api/d/docs?d=data/index&MR=1
use strict;
use warnings;
use Irssi qw(signal_emit signal_add print settings_get_str);
use LWP::UserAgent;
use Data::Dumper;
use JSON;
use utf8;
#
signal_add('weather','check_weather');
#
my $apikey = settings_get_str('weatherkey');
print (CRAP "no weather apikey") unless (defined($apikey));

my $json = new JSON;
my $ua   = new LWP::UserAgent;
$ua->agent(settings_get_str('myUserAgent'));
$ua->timeout(10);

my $country = 'argentina';

sub check_weather {
  my ($server,$chan,$city) = @_;
  $city =~ s/\s+/_/g;
  my $url = "http://api.wunderground.com/api/${apikey}/conditions/q/${city}_${country}.json";
  my $got = $ua->get($url);
  my $result = $json->utf8->decode($got->decoded_content);
  if (defined($result->{current_observation})) {
    my $temp        = $result->{current_observation}->{temp_c};
    my $lowest      = $result->{current_observation}->{dewpoint_c};
    my $weather     = $result->{current_observation}->{weather};
    my $humidity    = $result->{current_observation}->{relative_humidity};
    my $feelslike   = $result->{current_observation}->{feelslike_c};
    my $found_city  = $result->{current_observation}->{display_location}->{full};

    my $out = "${found_city}: ${weather}, Temp: ${temp}˚, Min: ${lowest}˚, Humedad: ${humidity}";
    sayit($server,$chan,$out);
  } else { sayit($server,$chan,"can't locate that city on planet Earth."); }
}

sub sayit {
  my ($server, $target, $msg) = @_;
  $server->command("MSG $target $msg");
}

