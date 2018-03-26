input {
        file {
                path => "/var/log/bigip/asm/*.log"
                start_position => beginning
                type =>"asmlogs"
        }
         file {
                path => "/var/log/bigip/http/*.log"
                start_position => beginning
                type =>"httplogs"
        }
        udp {
                port => 25826
                buffer_size => 1452
                codec => collectd {}
                type => "collectd"
        }




}
filter {
if [type] == "httplogs" {
        csv {
                separator => ","
                columns => [
                        "header",
                        "client_ip",
                        "client_port",
                        "virtual",
                        "method",
                        "hostname",
                        "port",
                        "request",
                        "version",
                        "referer",
                        "status",
                        "response_time",
                        "response_size",
                        "server_ip",
                        "server_port",
                        "User-Agent"
                ]
        }
         if [User-Agent] == "" {
                mutate {
                        update => {"User-Agent" => "None"}
                }
        }
    grok {
                match => { "header" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} " }
        }
        mutate {
                remove_field => [ "message", "header" ]
        }
        geoip {
                source => "client_ip"
                database => "/etc/logstash/GeoLite2-City/GeoLite2-City.mmdb"
        }
        date {
                match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
        }
}
if [type] == "asmlogs" {
    mutate {
                gsub => ["message","\"",""]
    }
    csv {
                separator => "#"
        columns => [
                        "header",
                        "geo_location",
                        "ip_address_intelligence",
                        "src_port",
                        "dest_ip",
                        "dest_port",
                        "protocol",
                        "method",
                        "uri",
                        "x_forwarded_for_header_value",
                        "request_status",
                        "support_id",
                        "session_id",
                        "username",
                        "violations",
                        "violation_rating",
                        "attack_type",
                        "query_string",
                        "policy_name",
                        "sig_ids",
                        "sig_names",
                        "sig_set_names",
                        "severity",
                        "request",
                        "violation_details"
                ]
    }
    grok {
       match => { "header" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} ASM:%{IP:source_ip}" }
    }
    geoip {
                source => "source_ip"
                database => "/etc/logstash/GeoLite2-City/GeoLite2-City.mmdb"
    }
    mutate {
                remove_field => [ "message", "header" ]
    }
    mutate {
                gsub => ["sig_set_names", "},{", "}#{"]
    }
date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
output {
        if [type] == "asmlogs" {
                elasticsearch {
                        hosts => ["10.1.20.8:9200"]
                        manage_template => false
                        index => "asm-index-%{+YYYY.MM.dd}"
                        document_type => "asm-log"
                }
                stdout {  }
        }
        if [type] == "httplogs" {
                elasticsearch {
                        hosts => ["10.1.20.8:9200"]
                        manage_template => false
                        index => "http-index-%{+YYYY.MM.dd}"
                        document_type => "http-log"
                }
                stdout {  }
        }
        if [type] == "collectd" {
                elasticsearch {
                        hosts => ["10.1.20.8:9200"]
                        manage_template => false
                        index => "collectd-index-%{+YYYY.MM.dd}"
                        document_type => "collectd-log"
                }
                stdout { }
        }

}
