{% set p  = salt['pillar.get']('appdynamics', {}) %}
{% set g  = salt['grains.get']('appdynamics', {}) %}


{%- set default_version      = '4.3.1.4' %}
{%- set default_prefix       = '/opt' %}
{%- set default_source_url   = 'https://s3-us-west-2.amazonaws.com/salt-artifacts2' %}
{%- set default_appd_user    = 'system-appdynamics' %}
{%- set default_account_name = 'appdynamics' %}
{%- set default_access_key   = 'changeme' %}
{%- set default_controller_host    = 'appdynamics.com' %}
{%- set default_controller_port    = '8090' %}
{%- set default_monitor_hardware   = 'true' %}
{%- set default_host_id      = 'appdynamics-salt-host' %}

{%- set version         = g.get('version', p.get('version', default_version)) %}
{%- set source_url      = g.get('source_url', p.get('source_url', default_source_url)) %}
{%- set prefix          = g.get('prefix', p.get('prefix', default_prefix)) %}
{%- set appd_user       = g.get('user', p.get('user', default_appd_user)) %}
{%- set account_name    = g.get('account_name', p.get('account_name', default_account_name)) %}
{%- set access_key      = g.get('access_key', p.get('access_key', default_access_key)) %}
{%- set controller_host = g.get('controller_host', p.get('controller_host', default_controller_host)) %}
{%- set controller_port = g.get('controller_port', p.get('controller_port', default_controller_port)) %}
{%- set enable_hardware_monitor = g.get('enable_hardware_monitor', p.get('enable_hardware_monitor', default_monitor_hardware)) %}
{%- set host_id         = salt['grains.get']('id', default_host_id) %}


{%- set appd_home  = salt['pillar.get']('users:%s:home' % appd_user, '/home/appdynamics') %}

{%- set appd = {} %}
{%- do appd.update( { 'version'         : version,
                      'source_url'      : source_url,
                      'home'            : appd_home,
                      'prefix'          : prefix,
                      'user'            : appd_user,
                      'account_name'    : account_name,
                      'access_key'      : access_key,
                      'controller_host' : controller_host,
                      'controller_port' : controller_port,
                      'enable_hardware_monitor': enable_hardware_monitor,
                      'host_id'         : host_id,
                  }) %}

