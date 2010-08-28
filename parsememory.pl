use strict;
my $k;
my $b_name;
my $name;
my $line;
my $number;
my $ntype;
my %db;
open(F,"<memory.txt");
while(<F>)
{
    chomp;
    $line = $_;
    if($b_name && /([\w]*) number/)
    {
        $ntype = $1;
        $line =~ /\"([\w\s\(\)\+\.\-]*)\"/;
        $number = $1;
        #print "$number\t$line\n" ;
        $b_name = 0;
        $db{"$name $ntype"} = $number;
    }

    if($line =~ /Formal name/)
    {
        $line =~ /\"([\w\s\(\)\.\-]*)\"/;
        $name = $1;
        #print "$line\t=Name: $name\n";
        $b_name = 1;
    }
}
close(F);
foreach $k (keys %db)
{
    print "$k\t$db{$k}\n";
}

