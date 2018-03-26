# Configuration files ELK with F5 Networks LTM/ASM

## Configure the securty profile with the right fields in the right order

The Security Log Profile for ASM must be set like this : 

```js
security log profile Log_ELK {
    application {
        Log_ELK {
            filter {
                request-type {
                    values { illegal-including-staged-signatures }
                }
                search-all { }
            }
            format {
                field-delimiter "#"
                fields { ip_client geo_location ip_address_intelligence src_port dest_ip dest_port protocol method uri x_forwarded_for_header_value request_status support_id session_id username violations violation_rating attack_type query_string policy_name sig_ids sig_names sig_set_names severity request violation_details }
            }
            local-storage disabled
            logic-operation and
            maximum-entry-length 64k
            protocol udp
            remote-storage remote
            servers {
                10.1.20.8:atm-zip-office { }
            }
        }
    }
}
``
