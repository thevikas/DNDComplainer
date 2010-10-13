#open(F,"grep -e ^..\- spammers |cut  -f 1|cut -b 1,2|");
use strict;

my (%operators_ctr,%circles_ctr,%operators,%circles);

open(F1,"<shortcode-operators");
while(<F1>)
{
    chomp;
    $operators{$1}=$2 if(/^(.):\s(.*)$/);    
}
close(F1);

open(F1,"<shortcode-circles");
while(<F1>)
{
    chomp;
    $circles{$1}=$2 if(/^(.):\s(.*)$/);    
}
close(F1);

open(F,"spammers");
while(<F>)
{
    chomp;
    if(/^(.)(.)\-/)
    {
        my $operatorcode = $1;
        my $circlecode = $2;
        print "$operatorcode$circlecode\t$operators{$operatorcode}\t$circles{$circlecode}\n";
        $operators_ctr{$operatorcode}++;
        $circles_ctr{$circlecode}++;
    }
}
close(F);
my $k;
print 
"\n
operator summary
----------------\n";
foreach $k (keys %operators_ctr)
{
    print "$operators{$k}\t$operators_ctr{$k}\n";
}

print 
"\n
circle summary
---------------\n";
foreach $k (keys %circles_ctr)
{
    print "$circles{$k}\t$circles_ctr{$k}\n";
}
