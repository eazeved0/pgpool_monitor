#!/usr/bin/perl
#

use DBI;

my $timeOut = 5;
my $random_n1 = int(rand(150));
my $random_n2 = int(rand(78));
my $active_conn = `ps -ef | grep \"pool: \" | grep -v wait | grep -v \"worker process\" | grep -v grep | wc -l`;
my $open_slots = `ps -ef | grep \"pool: wait\" | grep -v grep | wc -l`;
my $nagios_out = `/usr/lib/nagios/plugins/check_pgpool-II.pl -H localhost -P 9898 -U trer23 -W 12sw12bbs -d /usr/sbin -b 2 -p -w 1 -c 1`;
my $date = localtime;

$SIG{ALRM} = \&timeout;
$SIG{CHLD} = 'IGNORE',
alarm($timeOut);


my $pid = fork();
if ($pid) {
   print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
   print "Process started on: $date with process ID: $pid\n";
} elsif ($pid == 0) {


my $dbh = DBI->connect('dbi:Pg:dbname=example;host=127.0.0.1','example','example',{AutoCommit=>1,RaiseError=>1,PrintError=>0});
my $output = print "Successfully connected!\n";
print "Testing simple query... ",$dbh->selectrow_array("SELECT $random_n1*$random_n2"),"\n";
sleep(3);

} else {
   die "ERROR: Unable to create process: $!\n\n";

}

waitpid ($pid, 0);
alarm(0);

sub timeout {
   print "ERROR: Timeout connecting to PGPOOL!!\n\n";
   print "Collecting system outputs:\n";
   print "Active connections: $active_conn";
   print "Open slots: $open_slots";
   print "Nagios Output: $nagios_out";
#   my $warn = `/home/ubuntu/scripts/mail.pl &`;

  kill 9, $pid;
}


