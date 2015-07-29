use strict;   
use warnings;   
use Cwd;   
use Win32;   
use Digest::MD5 qw(md5 md5_hex md5_base64);   
use Storable;   
  
{   
    package FileEnumerator;   
    sub new{   
        my $class = shift;   
        ref($class) and die "Class Only for Object.";   
        my $doFunc = shift // sub{print @_,"\n"};   
           
        my %props = (   
            jobprocessor => $doFunc   
        );   
        bless \%props,$class;   
        ref(\%props) or die "Not cool!";   
        \%props;   
    }   
  
    sub _walkDir   
    {   
        ref(my $me = shift) or die "Instance Only";   
        my $curdir = shift @_;   
        my @nextd;   
        opendir my $cd,$curdir or die "cannot open $curdir";   
        while( my $f = readdir($cd) )   
        {   
            my $nf="$curdir/$f";   
               
            # interface needed: parseFile must be implemented   
            ${$me->{jobprocessor}}->parseFile($nf) if -f $nf;   
            push @nextd,$nf if -d $nf and $f !~ m/^(?:\.|\.\.)$/;   
        }   
        closedir $cd;   
        $me->_walkDir($_) foreach @nextd;   
    }      
           
    sub doWork{   
        ref(my $me = shift) or die "Instance Only";   
        my $startDir = shift;   
        die "not a valid directory.\n" if not -d $startDir;   
        $me->_walkDir($startDir);   
        1;   
    }   
       
    sub DESTROY {   
        ref(my $me=shift) or die "instance only";   
        #print "bye to \"$me\"\n";   
    }   
}   
  
{   
    package FileParser;   
    sub new{   
        my $class = shift;   
        ref($class) and die "Class Only for Object.\n";   
           
        my %data;   
        $data{dc}  = {};   
        $data{icon}= 0;         #icon url(s) from favorites' url   
        $data{iconurls} = 0;            #icon url(s) we got.   
        $data{parsed} = 0;      #url file we processed   
        bless \%data,$class;   
        ref(\%data) or die "Not cool!";   
        \%data;   
    }   
  
    sub parseFile   
    {   
        my $me = shift;   
        ref($me) or die "instance only.\n";   
        my $tf = shift or return;   
        return 0 if ($tf !~ m/\.url$/imx );   
           
        $me->{parsed}++;   
           
        open my $fin,$tf or die "cannot open $tf:$!";    
        my $insc = 0;   
        my ($curFavUrl, $curIcon);   
        while(<$fin>)   
        {   
            chomp;   
            /^\[(.*)\]$/imsx;   
            if($1)   
            {   
                my $a = $1;   
                $insc = $a =~ /InternetShortcut/imxs;   
                undef $curFavUrl;   
                next;   
            }   
               
            if ($insc)   
            {   
                my $a = $_;   
                if($a =~ /^URL=(.*)$/imxs )   
                {   
                    $curFavUrl = $1;   
                }   
                elsif( $a =~ /^IconFile=(.*)$/imxs )   
                {   
                    $curIcon = $1;   
                    $me->{icon}++;   
                }   
            }   
        }   
        close $fin or die "cannot close $tf:$!\n";   
  
        if( defined($curFavUrl) )   
        {   
            if( !defined($curIcon) )   
            {   
                if( $curFavUrl =~ /(https?:\/\/[\.a-z\d]+)/imxs )   
                {   
                    $curIcon = $1 . "/favicon.ico";   
                }   
            }   
               
            if( defined($curIcon) )   
            {   
                my $hashed = &Digest::MD5::md5_hex($curIcon);   
                $hashed = "\U$hashed";   
                my $dc = $me->{dc};   
                $dc->{$hashed} = [$curFavUrl,$curIcon];   
                $me->{iconurls}++;   
            }   
        }   
    }   
}   
  
my $parser = new FileParser;   
my $enumerator = new FileEnumerator(\$parser);   
my $ief  = Win32::GetFolderPath(0x0006) or die "cannot get favorites folder";   
$enumerator->doWork($ief);   
my $dc = $parser->{dc};   
  
while( my($k,$v) = each(%$dc))   
{   
    print $k,"\n",$v->[0],"\n",$v->[1],"\n\n";   
}   
  
print $parser->{parsed}," url(s) detected.\n";   
print $parser->{icon}," url(s) with icon parsed.\n";   
print $parser->{iconurls}," icon url(s).\n";   
  
# $dc is a hashref   
store $dc,"db.bin";  