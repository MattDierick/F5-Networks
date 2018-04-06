# iRule Geo Velocity by Paolo Di Liberto (F5 Italy)


This irule uses APM + ASM. It is called Geo-Velocity and User-Scoring. It allows to control where the user connects from and if this user is changing location to fast.
Then the irule controls via ASM how many violation this user did.

Over the threshold, the user will be prompted for an OTP via a Per-Request Policy.

You can see a full video demo on youtube : https://youtu.be/zPxmZUc_rGU

<img align="center" src="Global-policy.png">

<img align="center" src="Per-Req.png">

