#$Id$
use strict;
use Net::SMTP::TLS;
$|=1;

open(F,"<mailbox.info");
my $line = <F>;
close(F);
my ($email_user,$email_password) = split(/\|/,$line);

my $mailer = new Net::SMTP::TLS(
	'smtp.gmail.com',
	Hello   =>      'smtp.gmail.com',
	Port    =>      587,
	User    =>      $email_user,
	Password=>      $email_password);

print "SMTP connected.\n";

my $sentctr=0;
my $secs = 2;
my $modn = 1;
sub sendm
{
    my $sender = $_[0];
    my $dated = $_[1];

    return if(length $sender<2);
    $dated =~ s/\+530//gi;

    $mailer->mail('mevikas@gmail.com');
    $mailer->to('121@airtelindia.com');
    $mailer->data;
    $mailer->datasend("Subject: DND complaint by 9810524397 against $sender\n" .
		      "To: \"DND 121\" <121\@airtelindia.com>\n" .
		      'User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9pre) Gecko/2008050715 Thunderbird/3.0a1' . "\n" . 
		      "From: \"Vikas Yadav\" <mevikas\@gmail.com>\n\n" .

		      "From: $sender\n" .
		      "When: $dated\n" .
		      "what: advertisement\n" .
		      "My number: 9810524397\n");

    $mailer->dataend;
    $sentctr++;
    if($sentctr % $modn == 0)
    {
	print "sleeping at $sentctr for $secs seconds...";
	sleep $secs;
	print "woken.\n";
    }
}


my $data=0;
my ($sender2,$dated2,$line);
open(F,"<spammed");
my @lines = <F>;
close(F);

#lost many spam msgs
open(F,">spammed.out");
foreach $line (@lines)
{
    chomp $line;
    if($data)
    {
	if($line =~ /(^[^\@]*)\@(.*)$/gi)
	{
	    $sender2 = $1;
	    if($sender2 !~ /^SENT/)
	    {
		$dated2 = $2;
		print "$sender2 - $dated2\n";
		sendm($sender2,$dated2);
		$line = "SENT:$sender2 \@ $dated2";
	    }
	    $data=0;
	}
    }
    if($line =~ /===/)
    {
	if($data==1)
	{
	    
	}
	$data=1;
    }
    print F "$line\n";
}
close(F);

#sendm("myself","today 24th jan");

$mailer->quit;
