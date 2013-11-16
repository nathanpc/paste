#!/usr/bin/perl -w

# paste.pl
# PasteBin client.

use strict;
use warnings;

use Data::Dumper;
use LWP;

my $api_key = "d1c7004bf13191e23215fc12800afc5f";
my $server_url = "http://pastebin.com/api";
my $lwp = LWP::UserAgent->new;

# Prints the usage message.
sub usage {
	print "Usage: paste [login <username> <password>] [chkformat <format>] [parameter=<value>]\n";

	print "\nCommands\n";
	print "    login        Logs you in\n";
	print "    chkformat    Checks if your format string is valid for PasteBin\n";
	print "    help         This.\n";

	print "\nParameters\n";
	print "    name       Paste title\n";
	print "    format     Code format for highlighting\n";
	print "    private    Privacy level (0 = Public | 1 = Unlisted | 2 = Private)\n";
	print "    expire_date     Expiration date (N = Never | 10M = 10 Minutes | 1H = 1 Hour | 1D = 1 Day | 1M = 1 Month)\n";

	print "\nFor more information about the format string check out PasteBin's documentation: http://pastebin.com/api#5\n";
}

# Pretty-print parameters.
sub pretty_print_params {
	my ($params) = @_;

	# Loop through the hash.
	#for () {
	#	print "$name: $value\n";
	#}
}

# Logs in to PasteBin.
sub login {
	my $username = $ARGV[1];
	my $password = $ARGV[2];

	# Login.
	my $response = $lwp->post("$server_url/api_login.php", [
		"api_dev_key" => $api_key,
		"api_user_name" => $username,
		"api_user_password" => $password
	]);
	die "Error: ", $response->content, unless $response->is_success;

	print "Your authentication key is " . $response->content . "\n";

	# Save credentials.
	my $path = glob("~/.pastebin_key");
	open(FILE, ">:encoding(UTF-8)", $path)
		or die "Couldn't open $path: $!\n";
	print FILE $response->content;
	close(FILE);

	print "If you wish to logout, all you have to do is delete ~/.pastebin_key\n";
	exit(0);
}

# Paste.
sub paste {
	my ($paste, $params) = @_;
	my $req_params = {
		"api_dev_key"    => $api_key,
		"api_option"     => "paste",
		"api_paste_code" => $paste
	};

	#if (logged) {
		#"api_user_name"     => $username,
		#"api_user_password" => $password
	#}

	# TODO: Check if logged.
	      # Else, print a warning saying that the post will be anonymous.

	print "Pasting...\n";
	pretty_print_params($params);

	# Populate the URL params array.
	foreach my $key (keys %{ $params }) {
		$req_params->{"api_paste_" . $key} = $params->{$key};
	}

	# Paste.
	my $response = $lwp->post("$server_url/api_post.php", $req_params);
	die "Error:\n", $response->content, unless $response->is_success;

	print "Pasted: " . $response->content . "\n";  # TODO: Colorize the URL.
	# TODO: Maybe automatically put the URL in the clipboard?
}

# Main.
sub main {
	my $params = {};

	if (@ARGV gt 0) {
		# Got some arguments.
		if ($ARGV[0] eq "login") {
			login();
		} elsif ($ARGV[0] eq "help") {
			usage();
		} else {
			for (my $i = 0; $i < @ARGV; $i++) {
				my @arg = split("=", $ARGV[$i], 2);
				$params->{$arg[0]} = $arg[1];
			}
		}
	}

	my $file_contents = <STDIN>;
	if ($file_contents eq "\n") {
		usage();
	}

	#paste($file_contents, $params)
}

# Main program.
main();
