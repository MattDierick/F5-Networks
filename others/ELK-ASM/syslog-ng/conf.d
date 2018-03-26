options {
        create_dirs(yes);
        owner(root);
        group(root);
        perm(0777);
        dir_owner(root);
        dir_group(root);
        dir_perm(0777);
};
####################################################################
#Create per log type (e.g Device, HTTP) different source ports
source syslog_http_logs { udp(port(1519)); };
source syslog_asm_logs { udp(port(1520)); };

#####################################################################
#Filter the logs to be received only from the F5 devices that you require Add the IP addresses that will be used to send the logs of the F5 device
filter F5_IP {
        host("10.1.20.4");
};
#################################################################
#Create output files based on the log type
destination http_logs_file { file("/var/log/bigip/http/$HOST--$YEAR-$MONTH-$DAY-$HOUR.log"); };
destination asm_logs_file { file("/var/log/bigip/asm/$HOST--$YEAR-$MONTH-$DAY-$HOUR.log"); };

###################################################################
#Output the logs
log { source(syslog_http_logs);
      filter(F5_IP);
      destination(http_logs_file); };
log { source(syslog_asm_logs);
      filter(F5_IP);
      destination(asm_logs_file); };
