
# Use perl -MCPAN -e shell
# to install the module you want
# install File:Copy:Recursive
# install File:Remove

use 5.012;
use Cwd qw/getcwd/;
use File::Copy::Recursive qw/dircopy/;
use File::Remove qw/remove/;
use File::Find qw/find/;

sub toName{
	my @mn = qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
	$mn[shift];
}

my @srcdir = (
	'D:/GDVS/NextGen/CrazyDrill/lcomm',
	'D:/GDVS/NextGen/CrazyDrill/res',
	'D:/GDVS/NextGen/CrazyDrill/src'
);

my $target_dir = 'E:/Versions/CrazyDrillPack/';
for(@srcdir){
	dircopy($_, $target_dir . substr($_, rindex($_, '/')+1)) or die $!;
}

my $now = getcwd;
find(sub{
	my $full = $File::Find::name;
	# remove( \1, ($full, "*~")) if $full =~ /\.git$/imxs;
	if($full=~/\.git$/imxs){
		$full =~ s/\//\\/g;
		#print $full,"\n";
		system "rmdir $full /q/s";
		system "del /f/q $full";
	}
}, $now);

my($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime(time());
my $rar = sprintf("CrazyDrill_%s$day\_%02d%02d.rar", toName($mon), $hour, $min);
system "rar a $rar CrazyDrillPack";
die "packing failed" if $?;

my $scp = "\"C:/Program Files/Git/usr/bin/scp.exe\"";
system "$scp $rar eminem9\@192.168.210.170:/home/eminem9/Desktop/Public";
die "upload failed" if $?;
print "done\n";