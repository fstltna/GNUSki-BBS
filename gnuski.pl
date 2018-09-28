#!/usr/bin/perl
use strict;
use warnings;

use UI::Dialog;
use Term::ReadKey;
use Term::ANSIScreen qw(cls);
use Time::Piece;

my $StatsFileOutput = "/sbbs/doors/GNUSki-BBS/stats.txt";
my $ScoreFile = "/sbbs/doors/GNUSki-BBS/scores.txt";
my $GameEXE = "/sbbs/doors/GNUSki-BBS/gnuski";
my $GameScore = "/tmp/gnuski.score";
my $ClearCommand = "/usr/bin/clear";
my $SortCommand = "/usr/bin/sort";
my $MaxLines = 19;
my $HeadCommand = "/usr/bin/head -n $MaxLines";

###################################################
# No changes below here
###################################################

my $CR_ver = "1.0";

# Set UserName from command line
my $UserName = $ARGV[0];
if (!$UserName)
{
	print "You must supply the username as first argument!\n";
	exit 0;
}

my $d = new UI::Dialog ( backtitle => "GNUSki Version v$CR_ver", height => 20, width => 65, listheight => 5,
	order => [ 'ascii', 'cdialog', 'xdialog' ]);

my $windowtitle = "Welcome to GNUSki $UserName!";
my $enjoyedtitle = "We hope you enjoyed GNUSki $UserName!";

my $menuselection = "";

sub MainMenu
{
	$menuselection = $d->menu( title => 'Main Menu', text => 'Select one:',
                            list => [ '1', 'Play Game',
                                      '2', 'View Scores',
                                      'q', 'Quit' ] );
}

sub ProcessGame
{
	my $LastScore = 0;

	# Process the game scores
	# Pull in exit score
	open(my $fh, '<:encoding(UTF-8)', $GameScore) or die "Could not open file '$GameScore' $!";
	while (my $row = <$fh>)
	{
		chomp $row;
		$LastScore = $row;
	}
	close($fh);
	open(my $fh1, '>>', $StatsFileOutput) or die "Could not open file '$StatsFileOutput' $!";
	my $CurDate = localtime->strftime('%m/%d/%Y');
	print $fh1 "$LastScore\t$UserName\t$CurDate\n";
	close($fh1);
	system("$SortCommand -nrk1 $StatsFileOutput | $HeadCommand > lastscores");
	system("mv lastscores $StatsFileOutput");
	open(my $fh, '<', $StatsFileOutput) or die "Could not open file '$StatsFileOutput' $!";
	open(my $scoresfh, '>', $ScoreFile) or die "Could not open file '$ScoreFile' $!";
	while (my $row = <$fh>)
	{
		chomp $row;
		my ($Score, $Player, $Date) = split /\t/, $row;
		my $FormatString = sprintf("%5d %25s -  %s", $Score, $Player, $Date);
		print $scoresfh "$FormatString\n";
	}
	close($fh);
	close($scoresfh);
}

sub ViewScores
{
	if (! -f $ScoreFile)
	{
		system("$ClearCommand");
		print "No scores yet - play a game first!\n\n--- [ Press Return To Continue ] ---";
		my $input = <STDIN>;
		return;
	}
	open(my $fh, '<:encoding(UTF-8)', $ScoreFile) or die "Could not open file '$ScoreFile' $!";

	system("$ClearCommand");
	print "            GNUSki High Scores\n";
	print "---------------------------------------------\n";
	print "Score 			 Player    Date\n";
	print "---------------------------------------------\n";
 
	while (my $row = <$fh>)
	{
		chomp $row;
		print "$row\n";
	}
	close($fh);
	print "--- [ Press Return To Continue ] ---";
	my $input = <STDIN>;
}

while (-1)
{
	MainMenu();
	if (($menuselection eq "CANCEL") || ($menuselection eq "ESC") || ($menuselection eq "") || ($menuselection eq "q"))
	{
		$d->msgbox( title => $enjoyedtitle, text => "Thanks for playing..." );
		exit 0;
	}
	if ($menuselection eq "1")
	{
		# Run the game
		system("$GameEXE");
		ProcessGame();
	}
	elsif ($menuselection eq "2")
	{
		ViewScores();
	}
}

exit 0;
