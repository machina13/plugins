#!/usr/bin/env python
#
# Copyright 2011 Eytan Daniyalzade
# Modified 2012 Michael Will 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Checks if the specified ganglia metric, on specified host has a value that
# justifies an error, and returns with an exid code accordingly
# Usage:
#   >> python ganglia_metric_checker.py -H <hostname> -M <metric> --critical=<critical value> --warning=<warning value>

# Testing:
#   >> python check_ganglia_metric.py --file=data/sample.xml --metric=cpu_intr -H host1  --critical=1.4 --warning=2.4
#   out: ERROR - hostname host1, metric cpu_intr, val 3.0, critical 1.4


import re
import optparse

import socket

def netcat(hostname, port, content):
    """
    @param hostname: str
    @param port: int
    @param content: str
    @return data: str
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((hostname, port))
    s.sendall(content)
    s.shutdown(socket.SHUT_WR)
    data = ''
    while 1:
        cur_data = s.recv(1024)
        if cur_data == "":
            break
        data += str(cur_data)
    s.close()
    return data

VALUE_PARSING_RE = r'VAL=\"(.*?)\"'

def _get_ganglia_metrics(hostname, port, file_):
    """
    Returns string (xml) representation of ganglia metrics. If file_ is passed
    it will read the metrics from the file; otherwise, will ask ganglia running
    on hostname:port for these metric.
    @param hostname: str, nullable
    @param port: int, nullable
    @param file_: str, nullable
    @return ganglia_metrics: str
    """
    if file_:
        f = open(file_, 'r')
        return "".join(f.readlines())
    else:
        return netcat(hostname, port, '')

def _get_error_code(ganglia_metrics, hostname, metric_sre, warning, critical, inverted):
    """
    Extracts the value for metric on hostname from ganglia_metrics by regex,
    and returns an error code based on the warning/critical thresholds, assuming higher is better than lower
    i.e. for disk_free_percent_rootfs 
    @params ganglia_metrics: str
    @params hostname: str
    @params metric_sre: str 
    @params warning: float
    @params critical: float
    @params inverted: 
    @return error_code: int
    """

    lines = ganglia_metrics.split('\n')
    metric_re = re.compile(metric_sre)
    metric=0;
    for i, line in enumerate(lines):
        if hostname in line:
            for j in range(i, len(lines)):
                if metric_re.search(lines[j]):
#		    print "mw: %s" % lines[j]
                    m = re.search(VALUE_PARSING_RE, lines[j])
                    val = float(m.group(1))
		    metric+=val
                elif "</HOST>" in lines[j]:
		    if inverted:
			    if (not critical is None) and metric < critical:
				print ("CRITICAL - hostname %s, metric %s, val %s, critical %s | %s=%s" %
				       (hostname, metric_sre, metric, critical, metric_sre, metric))
				return(2)
			    if (not warning is None) and metric < warning:
				print ("WARNING - hostname %s, metric %s, val %s, warning %s | %s=%s" %
				       (hostname, metric_sre, metric, warning, metric_sre, metric))
				return(1)
		    else:
			    if (not critical is None) and metric > critical:
				print ("CRITICAL - hostname %s, metric %s, val %s, critical %s | %s=%s" %
				       (hostname, metric_sre, metric, critical, metric_sre, metric))
				return(2)
			    if (not warning is None) and metric > warning:
				print ("WARNING - hostname %s, metric %s, val %s, warning %s | %s=%s" %
				       (hostname, metric_sre, metric, warning, metric_sre, metric))
				return(1)

		    print ("OK - host %s metric %s=%s | %s=%s" %
			   (hostname, metric_sre, metric, metric_sre, metric))
		    return(0)

    print ("OK - no value for hostname %s, metric %s=%s | %s=%s" %
            (hostname, metric_sre, metric, metric_sre, metric))
    return(0)

def main():
    p = optparse.OptionParser()

    p.add_option('-F', '--file',
                    help="only used for debugging. will load the ganglia\
                    values from file instead of getting it from ganglia.",
                    )
    p.add_option('-G', '--ganglia_host', default='localhost',
                    help="host that ganglia is running on.",
                    )
    p.add_option('-P', '--ganglia_port', type=int, default=8649,
                    help="port that ganglia is running on.",
                    )
    p.add_option('-H', '--hostname',
                    help="hostname to check the metric for.",
                    )
    p.add_option('-M', '--metric',
                    help="metric to check the value of.",
                    )
    p.add_option('-W', '--warning', type=float, default=None,
                    help="warning value",
                    )
    p.add_option('-C', '--critical', type=float, default=None,
                    help="critical value",
                    )
    #p.add_option('-I', '--invert', type=int, default=None,
    p.add_option('-I', '--invert',  action="store_true", dest="invert", default=False,
                    help="check to stay above instead of below critical value",
                    )

    options, arguments = p.parse_args()
    #if not options.critical and not options.warning:
        #print 'USER_ERROR - must provide either a critical or warning value'
       # return -1
    metrics = _get_ganglia_metrics(options.ganglia_host,
                                    options.ganglia_port,
                                    options.file,
                                    )
    error_code = _get_error_code(metrics, options.hostname, options.metric,
				 options.warning,
				 options.critical,
				 options.invert
				 )
    return error_code

if __name__ == '__main__':
    try:
        exit(main())
    except Exception, e:
        print 'WARNING - failed %s' % e
        exit(1)

