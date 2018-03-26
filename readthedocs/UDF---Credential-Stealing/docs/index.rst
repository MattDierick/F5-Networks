Welcome to F5 Networks - Credential Stealing lab documentation
==============================================================

Introduction
============

.. warning:: For any comment, improvement or mistake, please contact Matthieu DIERICK (m.dierick@f5.com)

This documentation explains you how to demonstrate F5 Networks Credential Stealing solution in order to protect credentials against “credential grabbing”.

In order to build this lab you need:

*	1 x BIGIP FPS + any other module (LTM, ASM, AFM)
* 1 x BIG-IQ CM
* 1 x BIG-IQ DCD
*	1 x FPS license

To do so, we need to enable an FPS profile on the Virtual Server publishing the application. This FPS profile will get 2 features enabled :

*	Websafe Application Layer Encryption
* Websafe Anti-Phishing solution


.. toctree::
   :maxdepth: 2
   :caption: BIG-IP Configuration:

   configuration_BIGIP/Alert_Pool.rst
   configuration_BIGIP/Profile_FPS.rst


.. toctree::
  :maxdepth: 2
  :caption: BIG-IQ Configuration:

  configuration_BIGIQ/Configure_DCD.rst
  configuration_BIGIQ/Configure_BIGIQ_CM.rst

.. toctree::
   :maxdepth: 2
   :caption: Test and check the results:

   tests/Test_encryption.rst
   tests/Test_Phishing.rst

.. raw:: html

  <div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; height: auto;">
    <iframe width="560" height="315" src="https://www.youtube.com/embed/UumIWbhnLkk" frameborder="0" allowfullscreen></iframe>
  </div>
