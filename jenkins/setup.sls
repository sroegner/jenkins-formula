{% from "jenkins/map.jinja" import jenkins with context %}
{% from 'jenkins/macros.jinja' import jenkins_cli with context %}

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

jenkins.writeSshScript:
  file.managed:
    - name: {{ jenkins.home }}/init.groovy.d/sshAuthForAdmin.groovy
    - source: salt://jenkins/files/groovy/sshAuthForAdmin.groovy
    - template: jinja
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 644
    - require:
      - file: jenkins.initHookDirectory
    - watch_in:
      - cmd: restart_jenkins

jenkins.writeSetupScript:
  file.managed:
    - name: /tmp/setupJenkins.groovy
    - source: salt://jenkins/files/groovy/setupJenkins.groovy
    - template: jinja
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 644
    - watch_in:
      - cmd: restart_jenkins

jenkins.executeInitHookScript:
  cmd.run:
    - name: {{ jenkins_cli('groovy /tmp/setupJenkins.groovy') }}
    - runas: jenkins
    - require:
      - service: jenkins

{% endif %}
