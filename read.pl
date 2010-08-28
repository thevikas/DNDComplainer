use strict;
my $data=0;
my ($cmd,%autodel,$got);
my ($location,$folder,$dated,$sender,$data,$sms);
$|=1;
my @delete_queue;

system "mv spammed.out spammed" if(-f "spammed.out");

open(F,"gammu getallsms|");

my $can_delete=1;
my %friends;
my %spammers;
my ($k,%book,$v,$status_type);
open(F3,"memorydb.txt");
while(<F3>)
{
    chomp;
    ($k,$v) = split(/\t/);
    $book{$v} = $k;
}
close(F3);

open(F2,"autodelete");
while(<F2>)
{
    chomp;
    $autodel{$_}=1;
}
close(F2);

open(F2,"spammers");
while(<F2>)
{
    chomp;
    $spammers{$_}=1;
}
close(F2);

open(F2,"friends");
while(<F2>)
{
    chomp;
    $friends{$_}=1;
}
close(F2);


while(<F>)
{
    #print $_;
    chomp;
    if(/Location (\d*), folder "(\w*)", phone memory/)
    {
	my $nlocation = $1;
	my $nfolder = $2;
	
	if($data)
	{
	    sendmsg($sender,$dated,$sms,$location,$folder);
	    #print "from: $sender at $dated\n";
	    #print "msg: $sms\n";
	    $sender = $dated = $sms = $location = $folder = 'ERROR';
	}
	
	$location = $nlocation;
	$folder = $nfolder;
	
	#print "$location - $folder\n";
	
	$data=0;
	$sms="";
	
	next if($nfolder eq "Outbox");
    }
    if($data)
    {
	$sms .= $_;
    }
    if(/Remote number.*: \"([\w-+\s\.]*)\"/)
    {
	$sender = $1;
	#print "sender: $sender\n";
    }
    if(/Sent.*: (.*)$/)
    {
	$dated = $1;
	#print "dated: $dated\n";
    }
    if(/^Status.*: (.*)$/)
    {
        $status_type = $1;
        #print "status - $status_type\n";
        next if($status_type eq "Sent");
        next if($status_type eq "UnSent");
        $data = 1;
    }
    
}

sendmsg($sender,$dated,$sms,$location,$folder);

sub sendmsg
{
    my $sms0;
	$sender = $_[0];
	$dated = $_[1];
	$sms = $sms0 = $_[2];
    $location = $_[3];
    $folder = $_[4];

    $got = "";
	
    $sms =~ /^(.{30})/;
    my $snip = $1;
    print $location . "\n";
    if($friends{$sender}==1 && length $autodel{$sender} == 0)
    {
        print "friend ($sender) ignored.\n";
        return;        
    }

    if($spammers{$sender}==1)
    {
        savespammer($location,$sender,$dated,$sms0);
        print "spammer ($sender) ignored.\n";
        return;        
    }

    if(length $autodel{$sender}>0)
    {
	$got = "d";
	print "auto delete ($sender)\n";
	#sleep(1);
    }
    elsif(length $book{$sender}>0)
    {
        $got = "f" ;
    }
    else
    {
	    print "\n$sender ($book{$sender}) ($location) at $dated\n\t$snip\n";
	    print "Spam,Friend,Delete,Ok?:";
    	$got = <>;
    }

    #print "-$got\n";
    if($got =~ /d/gi)
    {
        justdelete($location,$sender,$dated,$sms0);
        return;
    }
	if($got =~ /f/gi)
    {
        open(F2,">>friends");
        print F2 "$sender\n";
        close(F2);
        $friends{$sender}=1;
        return;
    }
	if($got =~ /s/gi)
	{
        savespammer($location,$sender,$dated,$sms0);
	}
}

sub savespammer
{
    $location = $_[0];
    $sender = $_[1];
    $dated = $_[2];
    $sms = $_[3];

    my $loc = $location - 100000;

    open(F2,">>spammed");
    print F2 "$sender @ $dated\n$location\n$sms\n===\n";
    close(F2);

    open(F3,">>spammers");
    print F3 "$sender\n";
    close(F3);

    if($can_delete)
    {
        my $cmd = "gammu --deletesms 3 $loc ";
        print "deleting $location ($cmd)...";
        push @delete_queue,$cmd;
        print "Deleted";
    }

}
sub justdelete
{
    $location = $_[0];
    $sender = $_[1];
    $dated = $_[2];
    $sms = $_[3];

    my $loc = $location - 100000;

    my $cmd = "gammu --deletesms 3 $loc ";
    print "deleting $location ($cmd)...";
    push @delete_queue,$cmd;
    #system($cmd);  
    print "Deleted";
}


system("perl sendmail.pl");
$ctr = @delete_queue;
foreach $cmd (@delete_queue)
{
    print "\r$cmd... (left: $ctr)";
    system($cmd);
    $ctr--;
}
