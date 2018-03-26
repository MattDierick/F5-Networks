when RULE_INIT {
    set static::geoloc_timeout 1800
    set static::allowedViolations 3
}
    
when CLIENT_ACCEPTED {
    set static::lpub [HSL::open -publisher /Common/Splunk_APM_HSL_Pub]
}

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
            HSL::send $static::lpub "GEOVELOCITY ALERT!! User $user_name with IP $user_addr connected from $geocheck after connecting from $checkgeo"
        }
        apm_alert_badip {
            log local0. "BAD REPUTATION IP ALERT!! Connection from BAD IP $user_addr, [IP::reputation $user_addr]"
            HSL::send $static::lpub "BAD REPUTATION IP ALERT!! Connection from BAD IP $user_addr, [IP::reputation $user_addr]"
        }
        
        apm_alert_badgeo {
            log local0. "GEOCHECK ALERT!! Connection from unallowed country from IP  $user_addr, country is $geocheck"
            HSL::send $static::lpub "GEOCHECK ALERT!! Connection from unallowed country from IP  $user_addr, country is $geocheck"
        }
        
        apm_alert_baduser {
            set user_name [ACCESS::session data get "session.logon.last.username"]
            log local0. "BAD USER ALERT!! User $user_name with IP $user_addr connected from $geocheck has bad reputation"
            HSL::send $static::lpub "BAD USER ALERT!! User $user_name with IP $user_addr connected from $geocheck has bad reputation"
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
        
        asm_reputation_check {
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
        
        apm_check_user_score {
            #retrieve username and ip address
            set username [ACCESS::session data get "session.logon.last.username"]
            set srcip [ACCESS::session data get session.user.clientip]
        
            #search for violation per IP and username
            set ipviolations [table lookup -subtable "violators" $srcip]
            set userviolations [table lookup -subtable "badusers" $username]
        
            # if *both* username and IP address have bad reputation, set session variable to 1
            # the idea is to block just the bad user even if users share an ip address (e.g. snat)
            # and block the one using stolen credentials (from bad ip) and not the real user
            if { $ipviolations > $static::allowedViolations && $userviolations > $static::allowedViolations } {
                log local0. "user $username @ $srcip has Bad Reputation..do something!"
                ACCESS::session data set session.custom.user.badrepu 1
            }
            else {
                log local0. "user request ok"
                ACCESS::session data  set session.custom.user.badrepu 0
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
                log local0. "PerFlow user $username @ $srcip has Bad Reputation..do something!"
                ACCESS::perflow set perflow.custom 1
            }
          
     }
 }
