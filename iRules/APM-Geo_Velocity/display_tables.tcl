when HTTP_REQUEST {
            set html1 "<HTML><HEAD><TITLE>List of tables</TITLE></HEAD><BODY><CODE>"
        
            append html1 "List of username with last location<br>" 
            foreach username [table keys -subtable geoloc] {
            append html1 "$username | [table lookup -subtable geoloc $username]<br>"
            }
            
            append html1 "<br>List of username with violations<br>"
            foreach username [table keys -subtable badusers] {
            append html1 "$username | [table lookup -subtable badusers $username]<br>"
            }
            
            append html1 "<br>List of IP with violations<br>"
            foreach ip [table keys -subtable violators] {
            append html1 "$ip | [table lookup -subtable violators $ip]<br>"
            }
            
            append html1 "</CODE></BODY></HTML>"
            HTTP::respond 200 content "[subst $html1]"
            return

         }
         
         
when HTTP_RESPONSE {    
     HTTP::close
}