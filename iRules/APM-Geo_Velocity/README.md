# F5 Networks


This irule uses APM + ASM. It is called Geo-Velocity and User-Scoring. It allows to control where the user connects from and if this user is changing location to fast.
Then the irule controls via ASM how many violation this user did.

Over the threshold, the user will be prompted for an OTP via a Per-Request Policy.

<img align="center" src="VPE-Part1.png" height="64">
<img align="center" src="VPE-Part2.png" height="64">

<img align="center" src="Per-Req VPE.png" height="64">
