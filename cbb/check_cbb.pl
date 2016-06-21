#!/usr/bin/perl
#Plugin HP MCS 200 Cooling Unit
# http://www8.hp.com/uk/en/products/rack-cooling/product-detail.html?oid=6230883


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
print "-H = IP CBB\n";
print "-C = SNMP Community\n";
print "-m = Check type\n";
print "\thumidity\n";
print "\ttemperature_in\n";
print "\twarning_message\n";
print "\talarm_message\n";
print "\tcooling_capacity\n";
print "\ttemperature_out\n";
print "\tfan_1_rpm\n";
print "\tfan_2_rpm\n";
print "\tfan_3_rpm\n";
print "\tfanspeed\n";
print "\ttemp_1_in\n";
print "\ttemp_1_out\n";
print "\ttemp_2_in\n";
print "\ttemp_2_out\n";
print "\ttemp_3_in\n";
print "\ttemp_3_out\n";
print "\twater_temp_in\n";
print "\twater_temp_out\n";
print "\twater_flow\n";
print "\tvalve_setpoint\n";
print "\tstatus\n";
print "\tcondensate_duration\n";
print "\tcondensate_cycles\n";
print "\tfan_4_rpm\n";
print "\tfan_5_rpm\n";
print "\tfan_6_rpm\n";
print "\ttransfer_switch\n";
print "\tvalve_actual_value\n";
print "\tdewpoint_value\n";
print "\tfound_fans\n";
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
if ($opt_mode eq "humidity") {$type="humidity";}
if ($opt_mode eq "temperature_in") { $type="temperature_in";}
if ($opt_mode eq "warning_message") { $type="warning_message";}
if ($opt_mode eq "alarm_message") { $type="alarm_message";}
if ($opt_mode eq "cooling_capacity") { $type="cooling_capacity";}
if ($opt_mode eq "temperature_out") { $type="temperature_out";}
if ($opt_mode eq "fan_1_rpm") { $type="fan_1_rpm";}
if ($opt_mode eq "fan_2_rpm") { $type="fan_2_rpm";}
if ($opt_mode eq "fan_3_rpm") { $type="fan_3_rpm";}
if ($opt_mode eq "fanspeed") { $type="fanspeed";}
if ($opt_mode eq "temp_1_in") { $type="temp_1_in";}
if ($opt_mode eq "temp_1_out") { $type="temp_1_out";}
if ($opt_mode eq "temp_2_in") { $type="temp_2_in";}
if ($opt_mode eq "temp_2_out") { $type="temp_2_out";}
if ($opt_mode eq "temp_3_in") { $type="temp_3_in";}
if ($opt_mode eq "temp_3_out") { $type="temp_3_out";}
if ($opt_mode eq "water_temp_in") { $type="water_temp_in";}
if ($opt_mode eq "water_temp_out") { $type="water_temp_out";}
if ($opt_mode eq "water_flow") { $type="water_flow";}
if ($opt_mode eq "valve_setpoint") { $type="valve_setpoint";}
if ($opt_mode eq "status") { $type="status";}
if ($opt_mode eq "condensate_duration") { $type="condensate_duration";}
if ($opt_mode eq "condensate_cycles") { $type="condensate_cycles";}
if ($opt_mode eq "fan_4_rpm") { $type="fan_4_rpm";}
if ($opt_mode eq "fan_5_rpm") { $type="fan_5_rpm";}
if ($opt_mode eq "fan_6_rpm") { $type="fan_6_rpm";}
if ($opt_mode eq "transfer_switch") { $type="transfer_switch";}
if ($opt_mode eq "valve_actual_value") { $type="valve_actual_value";}
if ($opt_mode eq "dewpoint_value") { $type="dewpoint_value";}
if ($opt_mode eq "found_fans") { $type="found_fans";}

#OID
my $oid_humidity = "1.3.6.1.4.1.232.167.2.3.5.2.1.5.1";
my $oid_temperature_in = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.1";
my $oid_warning_message = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.2";
my $oid_alarm_message = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.3";
my $oid_cooling_capacity = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.4";
my $oid_temperature_out = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.5";
my $oid_fan_1_rpm = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.6";
my $oid_fan_2_rpm = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.7";
my $oid_fan_3_rpm = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.8";
my $oid_fanspeed = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.9";
my $oid_temp_1_in = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.10";
my $oid_temp_1_out = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.11";
my $oid_temp_2_in = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.12";
my $oid_temp_2_out = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.13";
my $oid_temp_3_in = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.14";
my $oid_temp_3_out = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.15";
my $oid_water_temp_in = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.16";
my $oid_water_temp_out = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.17";
my $oid_water_flow = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.18";
my $oid_valve_setpoint= "1.3.6.1.4.1.232.167.2.4.5.2.1.5.19";
my $oid_status = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.20";
my $oid_condensate_duration = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.21";
my $oid_condensate_cycles = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.22";
my $oid_fan_4_rpm = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.23";
my $oid_fan_5_rpm = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.24";
my $oid_fan_6_rpm = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.25";
my $oid_transfer_switch = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.26";
my $oid_valve_actual_value = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.27";
my $oid_dewpoint_value = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.28";
my $oid_found_fans = "1.3.6.1.4.1.232.167.2.4.5.2.1.5.29";


#Conexion SNMP
($session, $error)=Net::SNMP->session(
                                      hostname=>$opt_H,
                                      community=>$opt_C); die "error de sesion: $error" unless($session);
#Valida el sensor para extraer la informacion
if ($type eq "humidity") { push(@snmpoids, $oid_humidity);}
if ($type eq "temperature_in") { push(@snmpoids, $oid_temperature_in);}
if ($type eq "warning_message") { push(@snmpoids, $oid_warning_message);}
if ($type eq "alarm_message") { push(@snmpoids, $oid_alarm_message);}
if ($type eq "cooling_capacity") { push(@snmpoids, $oid_cooling_capacity);}
if ($type eq "temperature_out") { push(@snmpoids, $oid_temperature_out);}
if ($type eq "fan_1_rpm") { push(@snmpoids, $oid_fan_1_rpm);}
if ($type eq "fan_2_rpm") { push(@snmpoids, $oid_fan_2_rpm);}
if ($type eq "fan_3_rpm") { push(@snmpoids, $oid_fan_3_rpm);}
if ($type eq "fanspeed") { push(@snmpoids, $oid_fanspeed);}
if ($type eq "temp_1_in") { push(@snmpoids, $oid_temp_1_in);}
if ($type eq "temp_1_out") { push(@snmpoids, $oid_temp_1_out);}
if ($type eq "temp_2_in") { push(@snmpoids, $oid_temp_2_in);}
if ($type eq "temp_2_out") { push(@snmpoids, $oid_temp_2_out);}
if ($type eq "temp_3_in") { push(@snmpoids, $oid_temp_3_in);}
if ($type eq "temp_3_out") { push(@snmpoids, $oid_temp_3_out);}
if ($type eq "water_temp_in") { push(@snmpoids, $oid_water_temp_in);}
if ($type eq "water_temp_out") { push(@snmpoids, $oid_water_temp_out);}
if ($type eq "water_flow") { push(@snmpoids, $oid_water_flow);}
if ($type eq "valve_setpoint") { push(@snmpoids, $oid_valve_setpoint);}
if ($type eq "status") { push(@snmpoids, $oid_status);}
if ($type eq "condensate_duration") { push(@snmpoids, $oid_condensate_duration);}
if ($type eq "condensate_cycles") { push(@snmpoids, $oid_condensate_cycles);}
if ($type eq "fan_4_rpm") { push(@snmpoids, $oid_fan_4_rpm);}
if ($type eq "fan_5_rpm") { push(@snmpoids, $oid_fan_5_rpm);}
if ($type eq "fan_6_rpm") { push(@snmpoids, $oid_fan_6_rpm);}
if ($type eq "transfer_switch") { push(@snmpoids, $oid_transfer_switch);}
if ($type eq "valve_actual_value") { push(@snmpoids, $oid_valve_actual_value);}
if ($type eq "dewpoint_value") { push(@snmpoids, $oid_dewpoint_value);}
if ($type eq "found_fans") { push(@snmpoids, $oid_found_fans);}

#Verifica tipo de sensor a medir y extrae la informaciondel OID
foreach my $snmpoid (@snmpoids) {
                  my $respuesta=$session->get_request($snmpoid);
                  my $salida = $respuesta->{$snmpoid};
                      print "Sensor $type=$salida | $type=$salida\n";
                      $session->close();
}
