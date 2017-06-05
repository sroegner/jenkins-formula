{% from "jenkins/map.jinja" import jenkins with context %}

{% if grains['os_family'] in ['RedHat', 'Debian'] %}
jenkins.upgradeStateFile:
  file.managed:
    - name: {{ jenkins.home }}/jenkins.install.UpgradeWizard.state
    - content: 2.61
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 644
    - require:
      - pkg: jenkins

jenkins.initHookDirectory:
  file.directory:
    - name: {{ jenkins.home }}/init.groovy.d
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 755
    - require:
      - pkg: jenkins

jenkins.initHookScript:
  file.managed:
    - name: {{ jenkins.home }}/init.groovy.d/initJenkins.groovy
    - source: salt://jenkins/files/groovy/initJenkins.groovy
    - template: jinja
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 644
    - require:
      - file: jenkins.initHookDirectory
    - watch_in:
      - cmd: restart_jenkins
{% endif %}
