#!/Strawberry/perl/bin -w
package GenStruc;
use strict;
use warnings;
use vars qw(@ISA @EXPORT);
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(connect_for);

sub connect_for{
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
	
};

sub table_structure {
	my($dbh_from,$table_from,$schema_from)=@_;
	my $sth = $dbh_from->prepare(
						"select column_name,data_type,character_maximum_length,is_nullable from information_schema.`COLUMNS` where table_schema=? and table_name=?")
						|| die $DBI::errstr;
	$sth->execute($schema_from,$table_from)|| die $DBI::errstr;
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
};

1