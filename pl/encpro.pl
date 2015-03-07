#! perl -w

use 5.008;
use strict;
use Cwd qw/getcwd/;

sub isException{
	my $a = shift or die "no parameters for str";
	return $a eq 'db' || $a eq 'imports';
}

sub isFileException{
	my $a = shift or die "no parameters for me";
	return $a eq 'load.lua' || $a eq 'unitstatus.lua';
}

sub walkSub{
	my $dir = shift or die "no specified directory";
	my $depth = shift;
	$depth += 0;
	opendir my $cd, $dir or die "cannot open $dir";
	my @next;
	while( my $f = readdir $cd ){
		my $full = $dir . '/' . $f;

		# Jump
		next if '.' eq $f or '..' eq $f;
		next if isException($f) and 0 == $depth;
		next if isFileException($f) and -f $full;
		
		if(-d $full){
			push @next, $full;
			next;
		}
		if( $f =~ /\.lua/imxs){
			my $a = $full;
			$a =~ s/\//\\/g;
			#print $a,"\n";
			print "\"$full\"\n";
		}
	}
	closedir $cd;

	for(@next){
		walkSub($_, $depth + 1);
	}
}

sub main{
	my $target = "E:/Projects/XChange/DebugZeroman/commercial";
	die "no target" if not -d $target;
	walkSub($target, 0);
}

#Entry
main;

