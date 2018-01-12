#!/usr/bin/env perl
#
#           rt.pl -- a script to extract the routing table
#                    from a router.
#
#Set behavior
$snmpro='private=string';
#
$x=0;
$snmpwalk="/usr/bin/snmpwalk -v 1 -c $snmpro";
#$snmpget="/usr/bin/snmpget -v 1 -c $snmpro";
chomp ($rtr=$ARGV[0]);
if ( $rtr eq "" ) {die "$0: Must specify a router\n"};
print "Destination\tMask\t\tNexthop";
print "\t\t Proto\tInterface\n";
@iftable=`$snmpwalk $rtr ifDescr`;
#@iftable=qq{$snmpwalk $rtr ifDescr};
for $ifnum (@iftable) {
    chomp (($intno, $intname) = split (/ = /, $ifnum));
    $intno=~s/.*ifDescr\.//;
    $intname=~s/"//gi;
    $int{$intno}=$intname;
}

@ipRouteDest=`$snmpwalk $rtr ipRouteDest`;
@ipRouteDest=`$snmpwalk $rtr ipRouteDest`;
@ipRouteMask=`$snmpwalk $rtr ipRouteMask`;
@ipRouteNextHop=`$snmpwalk $rtr ipRouteNextHop`;
@ipRouteProto=`$snmpwalk $rtr ipRouteProto`;
@ipRouteIfIndex=`$snmpwalk $rtr ipRouteIfIndex`;
for $intnum (@ipRouteIfIndex) {
    chomp (($foo, $int) = split (/= /, $intnum));
    chomp (($foo, $dest) = split (/: /, @ipRouteDest[$x]));
    chomp (($foo, $mask) = split (/: /, @ipRouteMask[$x]));
    chomp (($foo, $nhop) = split (/: /, @ipRouteNextHop[$x]));
    chomp (($foo, $prot) = split (/= /, @ipRouteProto[$x]));
    #chomp (($foo, $metr) = split (/= /, @ipRouteMetric1[$x]));
    $int1 = $int{$int};
    if ($int1 eq '') {$int1="Local"};
    $prot=~s/\(.*//; $prot=~s/ciscoIgrp/\(e\)igrp/;
    printf ("%-15s %-15s %-15s %7s %-25s\n",$dest, $mask, $nhop, $prot, $int1);
    $x++
}
