#!/usr/bin/env perl -w

use strict;
use warnings;
use Digest::MD5::File qw/file_md5_hex/;
use File::stat;
use FileHandle;
use JSON::Syck;

my @CHARS =
  qw/0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z/;

my $fh = FileHandle->new( 'font.dat', 'w' );

# fontdata.090925/09/04/FTIME01/A.png -> 09:04AM[type:A]
# 09:04(544) - 19:07(1147)

my %imgs = ();
my %info = ();
printf STDERR "retrieving %d chars...\n", scalar(@CHARS);
my $cnt = 0, my $cnt2 = 0;
for ( my $c = 0 ; $c < scalar(@CHARS) ; $c++ ) {
    my $char = $CHARS[$c];
    printf STDERR $char;
    my $index = 0;
    for ( my $t = 544 ; $t < 1147 ; $t++ ) {
        my $m = $t % 60;
        my $h = ( $t - $m ) / 60;
        my $path =
          sprintf( 'fontdata.090925/%02d/%02d/FTIME01/%s.png', $h, $m, $char );
        die 'file not found[' . $path . ']' unless ( -f $path );
        my $id = file_md5_hex($path);

        # info
        $info{$char} ||= [];
        $info{$char}->[$index] = $id;

        $cnt++;

        # この順序逆にしたら、全部取る
        next if ( $imgs{$id} );
        $index++;

        $cnt2++;
        $imgs{$id} = $path;

        # [md5_hex(32bytes),filelen(4ytes),file][...] -> PATH_DATFILE
        $fh->print($id);
        my $len = stat($path)->size;
        $fh->print( pack( 'N', $len ) );
        my $buf;
        my $fh_tmp = FileHandle->new($path);
        while ( $fh_tmp->read( $buf, 10240 ) ) {
            $fh->print($buf);
        }
    }
}
printf STDERR "[%d/%d]\n", $cnt, $cnt2;

my $fh_js = FileHandle->new( 'font.js', 'w' );
print $fh_js JSON::Syck::Dump( \%info );

exit(0);
