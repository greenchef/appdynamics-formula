{%- from 'conf/settings.sls' import appd with context %}

### APPLICATION INSTALL ###
unpack-appdynamics-tarball:
  archive.extracted:
    - name: {{ appd.prefix }}/appdynamics
    - source: {{ appd.source_url }}/machineagent-bundle-64bit-linux-{{ appd.version }}.zip
    - source_hash: {{ salt['pillar.get']('appd:source_hash', '') }}
    - archive_format: zip
    - user: appdynamics
    - if_missing: {{ appd.prefix }}/appdynamics-{{ appd.version }}
    - keep: True
    - require:
      - module: appdynamics-stop
      - file: appdynamics-init-script
      - user: appdynamics
    - listen_in:
      - module: appdynamics-restart

fix-appdynamics-filesystem-permissions:
  file.directory:
    - user: appdynamics
    - recurse:
      - user
    - names:
      - {{ appd.prefix }}/appdynamics/appdynamics-agent
      - {{ appd.prefix }}/appdynamics/machineagent-bundle-64bit-linux-{{ appd.version }}
      - {{ appd.home }}
    - watch:
      - archive: unpack-appdynamics-tarball

create-appdynamics-symlink:
  file.symlink:
    - name: {{ appd.prefix }}/appdynamics/appdynamics-agent
    - target: {{ appd.prefix }}/appdynamics/machineagent-bundle-64bit-linux-{{ appd.version }}
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
      - file: appdynamics-init-script

# used to trigger restarts by other states
appdynamics-restart:
  module.wait:
    - name: service.restart
    - m_name: appdynamics

appdynamics-stop:
  module.wait:
    - name: service.stop
    - m_name: appdynamics

appdynamics-init-script:
  file.symlink:
    - name: '/etc/systemd/system/appdynamics.service'
    - target: '{{ appd.prefix }}/appdynamics/appdynamics-agent/etc/systemd/system/appdynamics-machine-agent.service'
    - user: root

appdynamics:
  user.present

### FILES ###
{{ appd.prefix }}/appdynamics/appdynamics-agent/conf/controller-info.xml:
  file.managed:
    - source: salt://appdynamics/templates/controller-info.xml.tmpl
    - user: {{ appd.user }}
    - template: jinja
    - listen_in:
      - module: appdynamics-restart
