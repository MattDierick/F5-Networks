when RULE_INIT {
    set static::geoloc_timeout 1800
    set static::allowedViolations 3
}

#### The section below is only used in case of SNAT in front of the APM. The ACCESS_SESSION_STARTED event will set the XFF as source IP@ and will set Geoloc and IP reputation

when ACCESS_SESSION_STARTED
{
        set clientIP [HTTP::header x-forwarded-for]
        log local0. "clientIP: $clientIP"
        ACCESS::session data set session.user.clientip $clientIP

        set ip_reputation_categories [IP::reputation $clientIP]
        ACCESS::session data set session.custom.iprep 0

        if {($ip_reputation_categories contains "Windows Exploits")} {
	        ACCESS::session data set session.custom.iprep 1 
	        } 
        if {($ip_reputation_categories contains "Web Attacks")} {  
		    ACCESS::session data set session.custom.iprep 1 
	        } 
	    if {($ip_reputation_categories contains "Scanners")}{  
		    ACCESS::session data set session.custom.iprep 1 
	        } 
	    if {($ip_reputation_categories contains "Proxy")}{  
		    ACCESS::session data set session.custom.iprep 1
	        }
	    if {($ip_reputation_categories contains "Tor")}{  
		    ACCESS::session data set session.custom.iprep 1
	         }
	    if {($ip_reputation_categories contains "Spam")}{  
		    ACCESS::session data set session.custom.iprep 1
         }

        log local0. "IP $clientIP is in continent [lindex [whereis $clientIP] 0] and country [lindex [whereis $clientIP] 1]"

        ACCESS::session data set session.custom.country [lindex [whereis $clientIP] 1]
}

### End of section for SNAT use case

### The section below HTTP_REQUEST will reset the counters for demo purpose

when HTTP_REQUEST
{
    if {[HTTP::uri] starts_with "/reset" }
        {
        log local0. "RESET Table"
        table delete -all -subtable geoloc
        table delete -all -subtable violators
        table delete -all -subtable badusers
        }

}

### End of section



when ACCESS_POLICY_AGENT_EVENT {
    set policyid [ACCESS::policy agent_id]
    log local0. "Policy id is: $policyid"

    set user_addr [ACCESS::session data get "session.user.clientip"]
    set geocheck [whereis $user_addr country]

    switch [ACCESS::policy agent_id] {

        apm_alert_geovelocity {
            set user_name [ACCESS::session data get "session.logon.last.username"]
            set checkgeo [table lookup -subtable geoloc -notouch $username]
            log local0. "GEOVELOCITY ALERT!! User $user_name with IP $user_addr connected from $geocheck after connecting from $checkgeo"
        }
        apm_alert_badip {
            log local0. "BAD REPUTATION IP or LOW IP SCORE ALERT!! Connection from BAD IP $user_addr, [IP::reputation $user_addr]"
        }

        apm_alert_badgeo {
            log local0. "GEOCHECK ALERT!! Connection from unallowed country from IP  $user_addr, country is $geocheck"
        }

        apm_alert_baduser {
            set user_name [ACCESS::session data get "session.logon.last.username"]
            log local0. "BAD USER ALERT!! User $user_name with IP $user_addr connected from $geocheck has bad reputation"
        }

        geo_set {
            set username [ACCESS::session data get session.logon.last.username]
            set ipadd [ACCESS::session data get session.user.clientip]
            log local0. "username is $username"
            set geolocation [whereis $ipadd country]
            log local0. "state is $geolocation"
            table set -subtable geoloc $username $geolocation $static::geoloc_timeout
            set checkgeo [table lookup -subtable geoloc -notouch $username]
            log local0. "checkgeo is $checkgeo"
        }

        geo_vel_check {
            set username [ACCESS::session data get session.logon.last.username]
    	    set ipadd [ACCESS::session data get session.user.clientip]
    	    set geolocation [whereis $ipadd country]
    	    set checkgeo [table lookup -subtable geoloc -notouch $username]
    	    if { $checkgeo != $geolocation && $checkgeo != "" } {
    		    #geo velocity alert!
    		    ACCESS::session data set session.custom.geoalert 1
    		    log local0. "Geo Velocity Alert! User $username has a previous connection from $checkgeo. New location is $geolocation"
    		}
    		else { 
                log local0. "No Geo Velocity Alert. User $username has a previous connection from $checkgeo. New location is $geolocation" 
    		    ACCESS::session data set session.custom.geoalert 0
    	    }
        }

        IP_asm_reputation_check {
            set srcip [ACCESS::session data get session.user.clientip]
            set userViolation [table lookup -subtable "violators" $srcip]
            if { $userViolation > $static::allowedViolations } {
                log local0. "Low ASM reputation IP"
                ACCESS::session data set session.custom.lowasmrepu 1
            }
            else {
                log local0. "Good enough ASM reputation IP"
                ACCESS::session data set session.custom.lowasmrepu 0
            }
        }

        USER_asm_reputation_check {
            #retrieve username
            set username [ACCESS::session data get "session.logon.last.username"]
            
            #search for violation per username
            set userviolations [table lookup -subtable "badusers" $username]

            if { $userviolations > $static::allowedViolations } {
                log local0. "user $username has Bad Reputation !"
                ACCESS::session data set session.custom.user.baduserrepu 1
            }
            else {
                log local0. "user $username is ok"
                ACCESS::session data  set session.custom.user.baduserrepu 0
            }
        }

        clear_user_score {
            set username [ACCESS::session data get "session.logon.last.username"]
            log local0. "User $username score cleared"
            table delete -subtable "badusers" $username
        }

    }
}


when ACCESS_PER_REQUEST_AGENT_EVENT {
     set id [ACCESS::perflow get perflow.irule_agent_id]

     #retrieve username and ip address
     set username [ACCESS::session data get "session.logon.last.username"]
     set srcip [ACCESS::session data get session.user.clientip]

     #search for violation per IP and username
     set ipviolations [table lookup -subtable "violators" $srcip]
     set userviolations [table lookup -subtable "badusers" $username]

     if { $id eq "check_user_rep_perflow" } {
         #log local0. "PerFlow User Reputation Check"
         ACCESS::perflow set perflow.custom 0
         if { $ipviolations > $static::allowedViolations && $userviolations > $static::allowedViolations } {
                #log local0. "PerFlow user $username @ $srcip has Bad Reputation..do something!"
                ACCESS::perflow set perflow.custom 1
            }
        }
     if { $id eq "reset_counters" }
     {
        table delete -subtable "badusers" $username
        table delete -subtable "violators" $srcip
     }


 }
