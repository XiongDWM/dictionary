#!/Strawberry/perl/bin -w
use strict;
use warnings;
use Win32::OLE;
use DBI;
sub retrieve_structure {
	my ($dsn_from,$user_from,$password_from,$database_from)=@_;
	#connect to database;
	my $dbh=DBI->connect($dsn_from,$user_from,$password_from)|| die $DBI::errstr;
	my $sth=$dbh->prepare(
				  "select table_name from information_schema.`TABLES` where table_schema=?")
				 ||die $DBI::errstr;
	$sth->execute($database_from)||die $DBI::errstr;
	while(my $table_for=$sth->fetchrow_hashref()){
		print "$table_for->{'TABLE_NAME'} \n";
		&table_structure($dbh,$table_for->{'TABLE_NAME'},$database_from);
	}
	#disconnect
	$dbh->disconnect();
	
}

sub table_structure {
	my($dbh_from,$table_from,$database_from)=@_;
	my $sth = $dbh_from->prepare(
						"select  from information_schema.`COLUMNS` where table_schema=? and table_name=?")
						|| die $DBI::errstr;
	$sth->execute($database_from,$table_from)|| die $DBI::errstr;
	while (my $ref=$sth->fetchrow_hashref()) {
		my $column_name =$ref->{'COLUMN_NAME'};
		my $data_type= $ref->{'DATA_TYPE'};		
		my $maximum=$ref->{'CHARACTER_MAXIMUM_LENGTH'}//'NULL';
		my $is_nullable=$ref->{'IS_NULLABLE'};
		print"$column_name $data_type $maximum $is_nullable \n";
		
		#the ref's tags should in uppercase
		#print "column_name:$ref->{'column_name'} \n data_type:$ref->{'data_type'} \n character_maximum_length=$ref->{'character_maximum_length'} \n is_nullable:$ref->{'is_nullable'}";
	}
	$sth->finish();	
}
print "hola \n";
print "enter host.......";
chomp(my $host=<STDIN>);
	
print "enter port.........";
chomp(my $port=<STDIN>);
	
	
print "enter database..........";
chomp(my $database=<STDIN>);
	
my $dsn="DBI:mysql:database=${database};host=${host};port=${port}";
		
print "enter user...........";
chomp(my $user=<STDIN>);
	
print "enter password......";
chomp(my $password=<STDIN>);


retrieve_structure($dsn,$user,$password,$database);
my $WAIT=<STDIN>;



=note
Dawei Xiong
wowrealmer@163.com
=CUT