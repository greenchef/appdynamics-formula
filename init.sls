{%- from 'appdynamics/conf/settings.sls' import appd with context %}

### APPLICATION INSTALL ###
unpack-appdynamics-tarball:
  archive.extracted:
    - name: {{ appd.prefix }}/appdynamics-sdk-native-nativeWebServer-64bit-linux-{{ appd.version }}.tar.gz
    - source: {{ appd.source_url }}/appdynamics-sdk-native-nativeWebServer-64bit-linux-{{ appd.version }}.tar.gz
    - source_hash: {{ salt['pillar.get']('appdynamics:source_hash', '') }}
    - archive_format: tar
    - user: {{ appd.user }}
    - if_missing: {{ appd.prefix }}/appdynamics-sdk-native-nativeWebServer-64bit-linux-{{ appd.version }}
    - keep: True
    - enforce_toplevel: False
    - require:
      - module: appdynamics-stop
#      - file: appdynamics-init-script
      - user: appdynamics
    - listen_in:
      - module: appdynamics-restart

fix-appdynamics-filesystem-permissions:
  file.directory:
    - user: appdynamics
    - recurse:
      - user
    - names:
      - {{ appd.prefix }}/appdynamics-sdk-native-nativeWebServer-64bit-linux-{{ appd.version }}
      - {{ appd.home }}
    - watch:
      - archive: unpack-appdynamics-tarball

create-appdynamics-symlink:
  file.symlink:
    - name: {{ appd.prefix }}/appdynamics-agent
    - target: {{ appd.prefix }}/appdynamics-sdk-native-nativeWebServer-64bit-linux-{{ appd.version }}
    - user: appdynamics
    - watch:
      - archive: unpack-appdynamics-tarball

### SERVICE ###
appdynamics-service:
  service.running:
    - name: appdynamics
    - enable: True
    - require:
      - archive: unpack-appdynamics-tarball
#      - file: appdynamics-init-script

# used to trigger restarts by other states
appdynamics-restart:
  module.wait:
    - name: service.restart
    - m_name: appdynamics

appdynamics-stop:
  module.wait:
    - name: service.stop
    - m_name: appdynamics

#appdynamics-init-script:
#  file.managed:
#    - name: '/lib/systemd/system/appdynamics-agent.service'
#    - source: salt://appdynamics/templates/appdynamics-machine-agent.service.tmpl #TODO - Do I really need an init script?
#    - user: root
#    - group: root
#    - mode: 0644
#    - template: jinja
#    - context:
#      appd: {{ appd|json }}

create-appdynamics-service-symlink:
  file.symlink:
    - name: '/etc/systemd/system/appdynamics.service'
    - target: '/lib/systemd/system/appdynamics-agent.service'
    - user: root
#    - watch:
#      - file: appdynamics-init-script

appdynamics:
  user.present

### FILES ###
{{ appd.prefix }}/appdynamics-agent/conf/controller-info.xml:
  file.managed:
    - source: salt://appdynamics/templates/controller-info.xml.tmpl
    - user: {{ appd.user }}
    - template: jinja
    - listen_in:
      - module: appdynamics-restart

{{ appd.prefix }}/appdynamics-agent/bin/machine-agent: # TODO
  file.managed:
    - source: {{ appd.prefix }}/appdynamics-agent/bin/machine-agent # TODO
    - user: {{ appd.user }}
    - mode: 0754
    - watch_in:
      - module: appdynamics-restart

{{ appd.prefix }}/appdynamics-sdk-native/proxy/jre/bin/java:
  file.managed:
    - source: {{ appd.prefix }}/appdynamics-sdk-native/proxy/jre/bin/java
    - user: {{ appd.user }}
    - mode: 0754
    - watch_in:
      - module: appdynamics-restart

{{ appd.prefix }}/appdynamics-agent/monitors/HardwareMonitor/monitor.xml:
  file.managed:
    - source: salt://appdynamics/templates/hardware-monitor.xml.tmpl
    - user: {{ appd.user }}
    - template: jinja
    - listen_in:
      - module: appdynamics-restart

{{ appd.prefix }}/appdynamics-agent/monitors/HardwareMonitor/linux-stat.sh:
  file.managed:
    - source: {{ appd.prefix }}/appdynamics-agent/monitors/HardwareMonitor/linux-stat.sh
    - user: {{ appd.user }}
    - mode: 0754
    - listen_in:
      - module: appdynamics-restart

/opt/sumologic/sumocollector/sources/appdynamics-agent.json:
  file.serialize:
    - user: root
    - formatter: json
    - dataset:
        "api.version": "v1"
        source:
          sourceType: LocalFile
          name: appd-agent
          pathExpression: {{ appd.prefix }}/appdynamics-agent/logs/machine-agent.log
