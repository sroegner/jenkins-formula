jenkins
=======

Available states
================

.. contents::
    :local:

``jenkins``
-----------

Install jenkins from the source package repositories and start it up.

``jenkins.nginx``
-----------------

Add a jenkins nginx entry. It depends on the nginx formula being installed and
requires manual inclusion `nginx` and `jenkins` states in your `top.sls` to
function, in this order: `jenkins`, `nginx`, `jenkins.nginx`.

`jenkins.plugins``
-----------------

Installs Jenkins plugins as listed in the `jenkins.plugins.installed` pillar, combined 
with the list of plugins normally suggested by the Jenkins SetupWizard feature.

The list of suggested plugins was taken from the jenkins sources:

.. code-block:: shell

    curl -sL https://github.com/jenkinsci/jenkins/raw/master/core/src/main/resources/jenkins/install/platform-plugins.json | jq -ra '(.[].plugins[] | select(.suggested==true)).name'

Pillar customizations:
==========================

.. code-block:: yaml

    jenkins:
      lookup:
        port: 80
        home: /usr/local/jenkins
        user: jenkins
        group: www-data
        server_name: ci.example.com

