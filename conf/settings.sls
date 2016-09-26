{% set p  = salt['pillar.get']('confluence', {}) %}
{% set g  = salt['grains.get']('confluence', {}) %}


{%- set default_version      = '4.2.7.0' %}
{%- set default_prefix       = '/opt' %}
{%- set default_source_url   = 'https://s3-us-west-2.amazonaws.com/salt-artifacts' %}
{%- set default_appd_user    = 'appdynamics' %}
{%- set default_account_name = 'appdynamics' %}
{%- set default_controller_host    = 'appdynamics.com' %}
{%- set default_controller_port    = '8090' %}

{%- set version         = g.get('version', p.get('version', default_version)) %}
{%- set source_url      = g.get('source_url', p.get('source_url', default_source_url)) %}
{%- set prefix          = g.get('prefix', p.get('prefix', default_prefix)) %}
{%- set appd_user       = g.get('user', p.get('user', default_appd_user)) %}
{%- set account_name    = g.get('account_name', p.get('account_name', default_account_name)) %}
{%- set controller_host = g.get('controller_host', p.get('controller_host', default_controller_host)) %}
{%- set controller_port = g.get('controller_port', p.get('controller_port', default_controller_port)) %}


{%- set appd_home  = salt['pillar.get']('users:%s:home' % appd_user, '/home/appdynamics') %}

{%- set appd = {} %}
{%- do appd.update( { 'version'         : version,
                      'source_url'      : source_url,
                      'home'            : appd_home,
                      'prefix'          : prefix,
                      'user'            : appd_user,
                      'account_name'    : account_name,
                      'controller_host' : controller_host,
                      'controller_port' : controller_port,
                  }) %}

