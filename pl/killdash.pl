
use 5.010;
use strict;
use warnings;
use Cwd qw/getcwd/;

{
    package State;
    sub new {
        ref(my $class=shift) and die "CLASS ONLY";
        my %dc = (
            entries => {}
        );
        bless \%dc, $class;
    }

    sub push {
        ref(my$me=shift) or die 'INSTANCE ONLY';
        my ($full, $f) = @_;
        my $entries = ${$me}{entries};
        ${$entries}{$full} = $f;
    }

    sub print {
        ref(my $me=shift) or die "INSTANCE ONLY";
        print "Debug info -----------\n";
        while(my($key, $value) = each %{${$me}{entries}}){
            print $value,"\n";
        }
        print "\n";
    }

    sub process {
        ref(my$me=shift)or die 'INSTANCE ONLY';
        while(my($full, $short) = each %{${$me}{entries}}){
            next if $short !~ /-/;
            $short =~ s/-/_/g;
            #print $short,"  -->  ", $sr, "\n";
            my $new = substr($full, 0, rindex($full, "/")) . "/$short";
            print $new,"\n";
            #die if not -f $full;
            # my $cmd = "mv";
            # $cmd = "rename" if $^O =~ "Win32";
            my $cmd = "git mv";
            $cmd .= " \"$full\" \"$new\"";
            system $cmd;
            die "rename error for $full" if $?;
        }
    }
}

sub walk {
    my $cur_d = shift // die "Need current directory";
    my $do = shift // die "No handler";
    my @nd;
    opendir my$cd, $cur_d or die "Cannot read dir:$cur_d\n";
    while( my $f = readdir $cd ) {
        next if grep{$_ eq $f}qw/. .. .git/;
        my $full = $cur_d . '/' . $f;
        if(-d $full){
            push @nd, $full
        } else {
            &$$do($full, $f)
        }
    }
    closedir $cd;
    walk($_, $do)for @nd;
}

die "Need sub folder name " if $#ARGV < 0;
my $now = getcwd . "/$ARGV[0]";
die "Not a folder for $now" if not -d $now;
my $o = State->new;
walk $now, \sub{
    $o->push(@_);
};
#$o->print;
$o->process;