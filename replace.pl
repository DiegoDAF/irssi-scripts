#replace.pl
use Irssi qw( command_bind signal_add print settings_get_str ) ;
use warnings;
use strict;

my %lastline;
my $delims = q(/|!@#$%&:;);
my $regex = qr{(?x-sm:
    ^s
      ([$delims])
        ( (?:\\.|(?!\1).)+ )
        #matchea \\ and a single char or lookahead un char que no sea un delimiter 
      \1                       #otro delimiter 
        ( (?:\\.|(?!\1).)* )
      \1?                      #cierre opcional
      (?:\s*\@(\w+))?           #optional username
)};
#m{^s([/|@])((?:(?!\1).)+)\1((?:.(?!\1).)*)\1?}) {

my $networks = settings_get_str('active_networks');

sub msg_pub {
  my ($server,$text,$nick,$mask,$chan) = @_;
  return if ($server->{tag} !~ /$networks/);
  return if ($text =~ /^!/);
  if ($text =~ $regex) {
    my $search;
    my $replace = $3;
    use re 'eval';
    eval { $search = qr/$2/; };
    if ($@) { sayit($server,$chan, "your regex is bad and you should feel bad"); return; }

    my $user = $4 if $4;
    my $nickToFind;
    if ($search) {
      if ($user) { $nickToFind = $user . $server->{tag}; }
      else { $nickToFind = $nick . $server->{tag}; }

      my $replaced = $lastline{$nickToFind};
      return if (!$replaced);
      if ($replaced =~ s{$search}{$replace}ig) {
        if (!$user) { sayit($server,$chan,"FTFY: $replaced"); }
        else { sayit($server,$chan,"$user quiso decir: $replaced"); }
      }
    }
  }
  else {
    #si no es s///, guardar la linea
    $lastline{"$nick"."$server->{tag}"} = $text;
  }
}
sub sayit {
  my ($server, $target, $msg) = @_;
  $server->command("MSG $target $msg");
}
Irssi::signal_add("message public","msg_pub");
