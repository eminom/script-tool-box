#! perl -w
use strict;
use warnings;
use 5.010;
use Cwd qw/getcwd/;

sub endsWith{
	my $name = shift // die "no input parameter";
	my $suffix = shift // die "no suffix";
	my $len0 = length($suffix);
	return length($name) >= $len0 
		&& substr($name, length($name) - $len0) eq $suffix;
}

sub isCczTarget{
	return endsWith($_[0], '.ccz');
}

sub getPngStr{
	my $name = shift // die "no input";
	my $sfix = '.pvr.ccz';
	if ( endsWith($name, $sfix)) {
		my $naked = substr($name, 0, length($name) - length($sfix));
		return ($naked . '.pvr', $naked . '.png');
	}
	undef;
}

sub walkNow{
	my $cd = shift or die "no current directory";
	my @nds;
	my @targets;
	opendir my $d, $cd or die "cannot open current dir";
	while( my $f = readdir $d )
	{
		my $ff = $cd . '\\' . $f;
		next if $f eq '.' or $f eq '..';
		push @nds, $ff if -d $ff;
		push @targets, $ff if -e $ff and not -d $ff and isCczTarget($f);
	}
	closedir $d;

	for my$o(@targets){
		my $cmd = "unccz \"$o\"";
		print "$cmd   ...";
		system($cmd);
		die "unccz failed: $?" if $?;
		print "done.\n";

		my ($in,$out) = getPngStr($o);
		if(defined($out)){
			my $cmd = "pvr -i \"$in\" -f ETC2_RGBA -d \"$out\"";
			$cmd =~ s/\//\\/g;
			print "$cmd\n";
			system($cmd);
			die "pvr decompressing error" if $?;
		} else {
			die "not here";
		}
	}

	walkNow($_) for(@nds);

}

sub main{
	walkNow getcwd();
}

main;
