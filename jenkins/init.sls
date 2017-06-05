{% from "jenkins/map.jinja" import jenkins with context %}

jenkins_group:
  group.present:
    - name: {{ jenkins.group }}
    - system: True

jenkins_user:
  file.directory:
    - name: {{ jenkins.home }}
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 0755
    - require:
      - user: jenkins_user
      - group: jenkins_group
  user.present:
    - name: {{ jenkins.user }}
    - groups:
      - {{ jenkins.group }}
    - system: True
    - home: {{ jenkins.home }}
    - shell: /bin/bash
    - require:
      - group: jenkins_group

jenkins:
  {% if grains['os_family'] in ['RedHat', 'Debian'] %}
    {% set repo_suffix = '' %}
    {% if jenkins.stable %}
      {% set repo_suffix = '-stable' %}
    {% endif %}
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    {% if grains['os_family'] == 'RedHat' %}
    - baseurl: http://pkg.jenkins-ci.org/redhat{{ repo_suffix }}
    - gpgkey: http://pkg.jenkins-ci.org/redhat{{ repo_suffix }}/jenkins-ci.org.key
    {% elif grains['os_family'] == 'Debian' %}
    - file: {{jenkins.deb_apt_source}}
    - name: deb http://pkg.jenkins-ci.org/debian{{ repo_suffix }} binary/
    - key_url: http://pkg.jenkins-ci.org/debian{{ repo_suffix }}/jenkins-ci.org.key
    {% endif %}
    - require_in:
      - pkg: jenkins
  {% endif %}
  pkg.installed:
    - pkgs: {{ jenkins.pkgs|json }}
  service.running:
    - enable: True
    - watch:
      - pkg: jenkins
      {% if grains['os_family'] in ['RedHat', 'Debian'] %}
      - file: jenkins config
      {% endif %}

{%- if grains['os_family'] in ['RedHat', 'Debian'] %}
jenkins config:
  file.managed:
    {% if grains['os_family'] == 'RedHat' %}
    - name: /etc/sysconfig/jenkins
    - source: salt://jenkins/files/RedHat/jenkins.conf
    {% elif grains['os_family'] == 'Debian' %}
    - name: /etc/default/jenkins
    - source: salt://jenkins/files/Debian/jenkins.conf
    {% endif %}
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - require:
      - pkg: jenkins

{%- if not jenkins.allow_wizard %}
jenkins.secretDirectory:
  file.directory:
    - name: {{ jenkins.home }}/secrets
    - mode: 700
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - require:
      - pkg: jenkins

jenkins.nonFakeAdminPassword:
  file.managed:
    - name: {{ jenkins.home }}/secrets/initialAdminPassword
    - contents: {{ jenkins.admin_password }}
    - mode: 400
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - require:
      - file: jenkins.secretDirectory
{%- endif %}
{%- endif %}
