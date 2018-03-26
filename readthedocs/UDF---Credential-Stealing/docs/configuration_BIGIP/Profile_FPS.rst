Create FPS Profile
==================

1.	Create an FPS profile in Security > Fraud Protection Service.


2.	Add an Alert Identifier and select the Alert Pool created in the previous steps

.. image:: ../images/Picture1.png
	:align: center
	:scale: 75%


3. Add an URL for the login page to protect. In our demonstration, /login.php.

.. warning:: Use lowercase only even if the page file has uppercase

.. image:: ../images/Config_BIGIP_URL.png
	:align: center

And enable Phishing, Application Layer Encryption and Login Page Properties.

.. image:: ../images/Config_profile_FPS.png
	:align: center

In the Login page properties, choose 302 HTTP response if the login page return a 302.


.. warning:: There is a known bug on V13.0. 302 redirection is not detected, so you have to select another method to detect Access Validation. You can use, for instance, the string "Welcome" to detect Access Validation to the webtop.


Then, add the 2 login page parameters, and check obfuscation and encryption boxes.

.. image:: ../images/FPS_Parameters.png
	:align: center
	:scale: 100%


.. warning:: Don't forget to assign your new FPS profile on the Virtual Server in the security tab.


.. image:: ../images/Virtual_security_tab.png
	:align: center

.. note:: Now, your BIGIP is ready and you must configure the BIGIQ in order to receive Phishing alerts
