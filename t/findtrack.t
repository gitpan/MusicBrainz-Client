BEGIN { $| =1;  print "1..1\n"; }
END { print "not ok 1\n" unless $loaded; }
#
# $Id: findtrack.t 636 2003-04-16 11:02:44Z sander $
#
use strict;
use MusicBrainz::Client;
use MusicBrainz::Queries qw(MBQ_FindTrackByName 
                            MBE_GetNumTracks
                            MBS_Rewind
                            MBS_SelectTrack
                            MBE_TrackGetTrackName
                            MBE_TrackGetArtistName
                            MBE_TrackGetArtistId);


use constant TRACK => "Headhunter";

use constant MB_SERVER => "mm.musicbrainz.org";
use constant MB_PORT   => 80;
use constant MB_DEBUG  =>  0;
use constant MB_DEPTH  =>  2;

my $mb = new MusicBrainz::Client();

if( $^O eq "MSWin32" )
{
    $mb->WSAInit();
}

# Tell the client library to return data in ISO8859-1 and not UTF-8
$mb->use_utf8(0);
# Tell the server to return 10 items.
$mb->set_max_items(10);
# Set the proper server to use. Defaults to mm.musicbrainz.org:80
$mb->set_server(MB_SERVER, MB_PORT);
# Check to see if the debug env var has been set
$mb->set_debug(MB_DEBUG);
# Tell the server to only return 2 levels of data, unless the MB_DEPTH var
# is set
$mb->set_depth(MB_DEPTH);

# Execute the MB_FindTrackByName query
my $ret = $mb->query_with_args( MBQ_FindTrackByName, [ TRACK ] );
unless( $ret ) {
   print "Query failed: ", $mb->get_query_error(), "\n";
   exit(0);
}

# Check to see how many items were returned from the server
my $num_albums = $mb->get_result_int( MBE_GetNumTracks );
if( $num_albums < 1 ) {
   print("No albums found.\n");
   exit(0);
}
print "Found ", $num_albums, " albums.\n\n";

for( my $i = 1; $i <= $num_albums; $i++ ) {
  # Start at the top of the query and work our way down
  $mb->select( MBS_Rewind );

  # Select the $i-th artist
  $mb->select1( MBS_SelectTrack, $i );

  # Extract the track name from the $i-th track
  my $data = $mb->get_result_data( MBE_TrackGetTrackName );
  printf("  Track: '%s'\n", $data || "");

  # Extract the artist name from the $i-th track
  $data = $mb->get_result_data( MBE_TrackGetArtistName );
  printf("  Artist: '%s'\n", $data || "");

  # Extract the artist id from the $-th track
  $data = $mb->get_result_data( MBE_TrackGetArtistId );
  my $temp = $mb->get_id_from_url($data) if($data);
  printf("  ArtistId: '%s'\n", $temp || "");
  print "\n"; 
}

if( $^O eq "MSWin32" )
{
    $mb->WSAStop();
}

our $loaded = 1;
print "ok 1\n";
