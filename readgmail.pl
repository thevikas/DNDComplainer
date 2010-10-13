    #use strict;
    #use warnings;
    use Net::IMAP::Simple::SSL;
    use Email::MIME;
    use base qw)Email::Simple);

$|=1;
open(F,"<mailbox.info");
my $line = <F>;
close(F);
my ($email_user,$email_password,$email_imap_server) = split(/\|/,$line);


    # Create the object
    my $imap = Net::IMAP::Simple::SSL->new($email_imap_server) ||
       die "Unable to connect to IMAP: $Net::IMAP::Simple::errstr\n";
    print "logging in...\n";
    # Log on
    if(!$imap->login($email_user,$email_password)){
        print STDERR "Login failed: " . $imap->errstr . "\n";
        exit(64);
    }

    # Print the subject's of all the messages in the INBOX
    my $nm = $imap->select('airtel-DND');
    print "all mail-" . $nm . "\n";
    my $failed = 0;
    for(my $i = 141; $i <= $nm; $i++){
        
        my $spammer;
        $spammer = "";
        my $es = Email::Simple->new(join '', @{ $imap->top($i) } );
        my $subject = $es->header('Subject');
        if($subject =~ /DND COMPLAINT BY 9810524397 AGAINST ([^\[]*) \[/)
        {
            my $msg;
            my $due_date;
            $spammer = $1;
            #printf("[%03d] %s\n", $i, $spammer);

            $msg = $imap->get($i);
            $msg =~ s/=\x0d\x0a//gi;
            
            #my $ebody = Email::Simple->new("\n" . $imap->get($i));
            #$msg = $ebody->body;
            #$msg =~ s/\=\n//gi;
            #print $msg;
            #die;
            #my $parsed = Email::MIME->new("\n" . $imap->get($i));
            #my $decoded = $parsed->body;
            #print "body = $decoded\n";
            #die;

            #$msg = $imap->get($i); #$ebody->body;

            #print $msg . "\n\n";
            next if($msg =~ /encoding: base64/);
    

            $msg =~ /[^\d](3\d{7})[^\d]/;
            my $srnumber2 = $1;
            if($msg =~ /Service Request number[^\d]*(\d{8})[^\d]/i)
            {
                $srnumber = $1;

                if($srnumber != $srnumber2)
                {
                    print "\n\n$msg\n";
                    print "$spammer\t$srnumber\t$srnumber2\n";
                    die;                
                }

            }
            else
            {
                print "no rnumber in $spammer ($srnumber2)\n";
                print $msg;
                print "\nno rnumber found";
                die;
                $failed++;
            }


            if($msg =~ /$srnumber.*[^\d](\d\d\/\d\d\/\d{2,4})[^\d]/i)
            {
                $due_date = $1;
                #print $msg;
                #print "due: $due_date";
                #<>;
            }
            else
            {
                #print $msg;
                #print "\nno date found";
                #die;
            }

            print "$spammer\t$srnumber\t$due_date\t$srnumber2\t($failed)\n";
            $srnumber = $due_date = $srnumber2 = 0;
        }
    }

    $imap->quit;

