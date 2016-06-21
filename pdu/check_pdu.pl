#!/usr/bin/perl
use strict;
use Net::SNMP;
use Data::Dumper;
use Getopt::Long;
&Getopt::Long::config('bundling');
my $host_ip=$ARGV[0];
my $host_comunidad=$ARGV[1];
my $host_puerto=161;
my $host_version_snmp=1;
my $type=$ARGV[2];
my $session;
my $error;
my ($opt_mode, $opt_h, $opt_C, $opt_P, $opt_H, $opt_w, $opt_c, $opt_t);
my $resultado ="";
my $exit_code="";
my $linea;
my %status_code = ("desconocido" => "3", "ok" => "0", "warning" => "1", "critical" => "2" );
my @snmpoids;

#Help de programa
sub FSyntaxError {
print "-H = IP PDU\n";
print "-C = SNMP Community\n";
print "-m = Check type\n";
print "\tphase_l1_current\n";
print "\tphase_l2_current\n";
print "\tphase_l3_current\n";
print "\tphase_l1_power\n";
print "\tphase_l2_power\n";
print "\tphase_l3_power\n";
print "\tphase_l1_voltage\n";
print "\tphase_l2_voltage\n";
print "\tphase_l3_voltage\n";
print "\tbank_1_load\n";
print "\tbank_2_load\n";
print "\tbank_3_load\n";
print "\tbank_4_load\n";
print "\tbank_5_load\n";
print "\tbank_6_load\n";
print "\tdevice_load\n";
print "\tenergy_total\n";

exit(3);
}
#Valida la cantidad de variables
if($#ARGV < 3 ) {
        FSyntaxError;
}
#Modo de uso
Getopt::Long::Configure('bundling');
GetOptions(

            "h"   => \$opt_h, "help"            => \$opt_h,
            "C=s" => \$opt_C, "host_comunidad"  => \$opt_C,
            "H=s" => \$opt_H, "host_ip"	        => \$opt_H,
            "m=s" => \$opt_mode, "mode"	        => \$opt_mode,
            "w=s" => \$opt_w, "warning=s"       => \$opt_w,
            "c=s" => \$opt_c, "critical=s"      => \$opt_c,
            "t=i" => \$opt_t, "timeout"         => \$opt_t);

# Validando variables entregadas
if ($opt_h) { FSyntaxError;};
if (! $opt_H) {print "No Hostname specified\n\n"; FSyntaxError; }
if ($opt_mode eq "phase_l1_current") { $type="phase_l1_current";}
if ($opt_mode eq "phase_l2_current") { $type="phase_l2_current";}
if ($opt_mode eq "phase_l3_current") { $type="phase_l3_current";}
if ($opt_mode eq "phase_l1_power") 	 { $type="phase_l1_power";}
if ($opt_mode eq "phase_l2_power") 	 { $type="phase_l2_power";}
if ($opt_mode eq "phase_l3_power") 	 { $type="phase_l3_power";}
if ($opt_mode eq "phase_l1_voltage") { $type="phase_l1_voltage";}
if ($opt_mode eq "phase_l2_voltage") { $type="phase_l2_voltage";}
if ($opt_mode eq "phase_l3_voltage") { $type="phase_l3_voltage";}
if ($opt_mode eq "bank_1_load") 		 { $type="bank_1_load";}
if ($opt_mode eq "bank_2_load") 		 { $type="bank_2_load";}
if ($opt_mode eq "bank_3_load") 		 { $type="bank_3_load";}
if ($opt_mode eq "bank_4_load") 		 { $type="bank_4_load";}
if ($opt_mode eq "bank_5_load") 		 { $type="bank_5_load";}
if ($opt_mode eq "bank_6_load") 		 { $type="bank_6_load";}
if ($opt_mode eq "device_load") 		 { $type="device_load";}
if ($opt_mode eq "energy_total")     { $type="energy_total";}

#Prefix
my $prefix;
if ($opt_mode eq "phase_l1_current") { $prefix="A";}
if ($opt_mode eq "phase_l2_current") { $prefix="A";}
if ($opt_mode eq "phase_l3_current") { $prefix="A";}
if ($opt_mode eq "phase_l1_power") 	 { $prefix="kW";}
if ($opt_mode eq "phase_l2_power") 	 { $prefix="kW";}
if ($opt_mode eq "phase_l3_power") 	 { $prefix="kW";}
if ($opt_mode eq "phase_l1_voltage") { $prefix="V";}
if ($opt_mode eq "phase_l2_voltage") { $prefix="V";}
if ($opt_mode eq "phase_l3_voltage") { $prefix="V";}
if ($opt_mode eq "bank_1_load") 		 { $prefix="A";}
if ($opt_mode eq "bank_2_load") 		 { $prefix="A";}
if ($opt_mode eq "bank_3_load") 		 { $prefix="A";}
if ($opt_mode eq "bank_4_load") 		 { $prefix="A";}
if ($opt_mode eq "bank_5_load") 		 { $prefix="A";}
if ($opt_mode eq "bank_6_load") 		 { $prefix="A";}
if ($opt_mode eq "device_load") 		 { $prefix="kW";}
if ($opt_mode eq "energy_total")     { $prefix="kWh";}

#OID
my $oid_phase_l1_current= "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.1"; 		# Amperes (/10)
my $oid_phase_l2_current= "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.2"; 		# Amperes (/10)
my $oid_phase_l3_current= "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.3"; 		# Amperes (/10)
my $oid_phase_l1_power=   "1.3.6.1.4.1.318.1.1.26.6.3.1.7.1";   		# kW (/100)
my $oid_phase_l2_power=   "1.3.6.1.4.1.318.1.1.26.6.3.1.7.2";   		# kW (/100)
my $oid_phase_l3_power=   "1.3.6.1.4.1.318.1.1.26.6.3.1.7.3";   		# kW (/100)
my $oid_phase_l1_voltage= "1.3.6.1.4.1.318.1.1.26.6.3.1.6.1";   		# Voltage (V)
my $oid_phase_l2_voltage= "1.3.6.1.4.1.318.1.1.26.6.3.1.6.2";   		# Voltage (V)
my $oid_phase_l3_voltage= "1.3.6.1.4.1.318.1.1.26.6.3.1.6.3";   		# Voltage (V)
my $oid_bank_1_load=      "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.4"; 		# Amperes
my $oid_bank_2_load=      "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.5";		  # Amperes
my $oid_bank_3_load=      "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.6"; 		# Amperes
my $oid_bank_4_load=      "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.7"; 		# Amperes
my $oid_bank_5_load=      "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.8"; 		# Amperes
my $oid_bank_6_load=      "1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.9"; 		# Amperes
my $oid_device_load=      "1.3.6.1.4.1.318.1.1.12.1.16.0";      		# kWatts (/1000)
my $oid_energy_total=     "1.3.6.1.4.1.318.1.1.26.4.3.1.9.1";       # kWh

#Conexion SNMP
($session, $error)=Net::SNMP->session(
                                      hostname=>$opt_H,
                                      community=>$opt_C);
																			die "error de sesion: $error" unless($session);
#Valida el sensor para extraer la informacion
if ($type eq "phase_l1_current") { push(@snmpoids, $oid_phase_l1_current);}
if ($type eq "phase_l2_current") { push(@snmpoids, $oid_phase_l2_current);}
if ($type eq "phase_l3_current") { push(@snmpoids, $oid_phase_l3_current);}
if ($type eq "phase_l1_power")   { push(@snmpoids, $oid_phase_l1_power);}
if ($type eq "phase_l2_power")   { push(@snmpoids, $oid_phase_l2_power);}
if ($type eq "phase_l3_power")   { push(@snmpoids, $oid_phase_l3_power);}
if ($type eq "phase_l1_voltage") { push(@snmpoids, $oid_phase_l1_voltage);}
if ($type eq "phase_l2_voltage") { push(@snmpoids, $oid_phase_l2_voltage);}
if ($type eq "phase_l3_voltage") { push(@snmpoids, $oid_phase_l3_voltage);}
if ($type eq "bank_1_load")      { push(@snmpoids, $oid_bank_1_load);}
if ($type eq "bank_2_load")      { push(@snmpoids, $oid_bank_2_load);}
if ($type eq "bank_3_load")      { push(@snmpoids, $oid_bank_3_load);}
if ($type eq "bank_4_load")      { push(@snmpoids, $oid_bank_4_load);}
if ($type eq "bank_5_load")      { push(@snmpoids, $oid_bank_5_load);}
if ($type eq "bank_6_load")      { push(@snmpoids, $oid_bank_6_load);}
if ($type eq "device_load")      { push(@snmpoids, $oid_device_load);}
if ($type eq "energy_total")     { push(@snmpoids, $oid_energy_total);}


#Verifica tipo de sensor a medir y extrae la informacion del OID
foreach my $snmpoid (@snmpoids) {
                  my $respuesta=$session->get_request($snmpoid);
                  my $dato = $respuesta->{$snmpoid};
									my $salida;
									#Genera informacion
									if ($type eq "phase_l1_current") { $salida=$dato/10;}
									if ($type eq "phase_l2_current") { $salida=$dato/10;}
									if ($type eq "phase_l3_current") { $salida=$dato/10;}
									if ($type eq "phase_l1_power")   { $salida=$dato/100;}
									if ($type eq "phase_l2_power")   { $salida=$dato/100;}
									if ($type eq "phase_l3_power")   { $salida=$dato/100;}
									if ($type eq "phase_l1_voltage") { $salida=$dato;}
									if ($type eq "phase_l2_voltage") { $salida=$dato;}
									if ($type eq "phase_l3_voltage") { $salida=$dato;}
									if ($type eq "bank_1_load")      { $salida=$dato/10;}
									if ($type eq "bank_2_load")      { $salida=$dato/10;}
									if ($type eq "bank_3_load")      { $salida=$dato/10;}
									if ($type eq "bank_4_load")      { $salida=$dato/10;}
									if ($type eq "bank_5_load")      { $salida=$dato/10;}
									if ($type eq "bank_6_load")      { $salida=$dato/10;}
									if ($type eq "device_load")      { $salida=$dato/1000;}
									if ($type eq "energy_total")     { $salida=$dato/10;}

                      print "PDU $opt_H $type=$salida$prefix | $type=$salida$prefix\n";
                      $session->close();
}
