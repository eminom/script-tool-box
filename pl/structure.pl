

use strict;
use warnings;
use Cwd qw/getcwd/;
use File::Path qw/make_path/;

{
    package Struct;
    sub new {
        ref(my $class = shift) and die 'CLASS ONLY';
        my $prefix = shift or die 'No prefix';  # xxx/x2
        my %dc = (
            map => {},
                ## NAME TO RELATE
                ## Button_Play.png -> button, e.g.
            prefix=> $prefix
        );
        bless \%dc, $class;
        \%dc
    }

    sub debug {
        ref(my $me=shift) or die 'INSTANCE ONLY';
        print "prefix is ${$me}{prefix}\n";
        print $me,"\n";
        while(my($k,$v) = each %{${$me}{map}} ) {
            print "$k => $v\n";
        }
    }

    sub record {
        ref(my $me =shift) or die 'INSTANCE ONLY';
        my $fpath = shift or die 'No input';
        my $prefix = ${$me}{prefix};
        my $rel = substr($fpath, length($prefix)+1);
        my $p = rindex $rel, '/';
        return if $p < 0;
        my $value = substr($rel, 0, $p);
        my $key   = substr($rel, $p+1);
        ${${$me}{map}}{$key} = $value;
    }

    sub query {
        ref(my $me=shift) or die 'INSTANCE ONLY';
        my $key = shift or die 'No input key';
        die "No such entry for $key" if not exists ${${$me}{map}}{$key};
        ${${$me}{map}}{$key};
    }
}

sub clone_dirs{
    my $pre = shift // die;
    my $now = shift // die;
    my $target = shift // die;
    my $cd = "$pre" . (length($now)>0 and "/$now" or '');
    my @nd;
    opendir my $cdin, $cd or die;
    while (my $f = readdir $cdin) {
        next if grep{$_ eq $f}qw/. .. outs/;
        my $full = "$cd/$f";
        next if not -d $full;
        my $relate = substr($full, length($pre) + 1);
        my $to_make = "$target/$relate";
        #print "=> $target/$relate\n";
        make_path $to_make;
        push @nd, (length($now)>0 and "$now/$f" or "$f")
    }
    closedir $cdin;
    clone_dirs($pre, $_, $target)for @nd;
}

sub walk_dirs {
    my $now = shift // die "No current directory";
    my $processor = shift // die "No processor";
    my @nd;
    opendir my $cd, $now or die "Cannot open $now";
    while ( my $f = readdir $cd ) {
        next if grep{$_ eq $f}qw/. .. outs/;
        my $full = "$now/$f";
        &$$processor($full) if -f $full;
        push @nd, $full if -d $full;
    }
    closedir $cd;
    walk_dirs($_, $processor) for @nd;
}

sub walk_one {
    my $now = shift // die "No folder";
    my $proc= shift // die "No processor";
    opendir my$cd,$now or die "Cannot open $now";
    while (my $f=readdir $cd) {
        next if grep{$_ eq $f}qw/. ../;
        my $full = "$now/$f";
        &$$proc($full) if -f $full;
    }
    closedir $cd;
}

sub main{
    my $source = shift @ARGV // die "No template folder specified";
    my $target = shift @ARGV // die "No target folder specified";
    my $origin = shift @ARGV // die "No origin for me";
    die "Not a fold for origin:$origin" if not -d $origin;
    $source =~ s/\///g;   #:No slash at all
    $target =~ s/\///g;
    my $cwd = getcwd;
    $target = $cwd . '/' . $target;
    die "Not a folder:$source" if not -d "$cwd/$source/";
    make_path $target;
    die "Cannot create folder:$target" if not -d $target;
    #clone_dirs "$cwd/$source", "", $target;
    my $o = Struct->new("$cwd/$source");
    walk_dirs "$cwd/$source", \sub{
        $o->record(@_);
    };
    # $o->debug;
    #print $o->query("Rocket_13.png"), "\n";

    walk_one $origin, \sub{
        my $full = shift // die "No ??";
        my $s = substr($full, rindex($full,'/')+1);
        my $t = $o->query($s);
        print "$s => $t\n";
        my $cmd = "cp";
        $cmd = "xcopy" if $^O =~ /Win32/;
        $cmd .= " \"$full\" \"$target/$t/$s\"";
        $cmd =~ s/\//\\/g if $^O =~ /Win32/;
        $cmd .= " /I" if $^O =~ /Win32/;
        #print $cmd,"\n";
        $cmd = "echo F|$cmd" if $^O =~ /Win32/;
        system $cmd;
        die if $?;
    };
    1;
}

#Entry:
#main;
#print length "Hello";
die "Need <Template Folder> <Output Folder>" if $#ARGV != 2;
main

