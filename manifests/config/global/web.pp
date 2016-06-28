# Author::    Wil Cooley <wcooley(at)nakedape.cc>
# License::   MIT
#
# == Class: rundeck::config::global::web
#
# Manage the application's +web.xml+.
#
# Currently only manages the +<security-role>+ required for any user to login and session timout:
# http://rundeck.org/docs/administration/authenticating-users.html#security-role
# http://rundeck.org/docs/administration/configuration-file-reference.html#session-timeout
#
# === Parameters
#
# [*security_role*]
#   Name of role that is required for all users to be allowed access.
#
# [*session_timeout*]
#   Session timeout is an expired time limit for a logged in Rundeck GUI user which as been inactive for a period of time.
#
# [*rundeck_config_global_web_sec_roles_true*]
# Boolen value if you want to have more roles in web.xml
#
# [*rundeck_config_global_web_sec_roles*]
# Array value if you set the value 'rundeck_config_global_web_sec_roles_true' to true and you have in hiera yaml file array:
#  rundeck::config::global::web::security_roles:
#    - DevOps
#    - roots_ito
#
class rundeck::config::global::web (
  $security_role                            = $rundeck::params::security_role,
  $session_timeout                          = $rundeck::params::session_timeout,
  $rundeck_config_global_web_sec_roles_true = $rundeck::rundeck_config_global_web_sec_roles_true,
  $rundeck_config_global_web_sec_roles      = $rundeck::rundeck_config_global_web_sec_roles,
) inherits rundeck::params {

  if $rundeck_config_global_web_sec_roles_true {
    rundeck::config::global::securityroles { $rundeck_config_global_web_sec_roles: }
  }
  else {
    augeas { 'rundeck/web.xml/security-role/role-name':
      lens    => 'Xml.lns',
      incl    => $rundeck::params::web_xml,
      changes => [ "set web-app/security-role/role-name/#text '${security_role}'" ],
    }
  }

  augeas { 'rundeck/web.xml/session-config/session-timeout':
    lens    => 'Xml.lns',
    incl    => $rundeck::params::web_xml,
    changes => [ "set web-app/session-config/session-timeout/#text '${session_timeout}'" ],
  }

  if $rundeck::preauthenticated_config['enabled'] {
    augeas { 'rundeck/web.xml/security-constraint/auth-constraint':
      lens    => 'Xml.lns',
      incl    => $rundeck::params::web_xml,
      changes => [ 'rm web-app/security-constraint/auth-constraint' ],
    }
  }
  else {
    augeas { 'rundeck/web.xml/security-constraint/auth-constraint/role-name':
      lens    => 'Xml.lns',
      incl    => $rundeck::params::web_xml,
      changes => [ "set web-app/security-constraint[last()+1]/auth-constraint/role-name/#text '*'" ],
      onlyif  => 'match web-app/security-constraint/auth-constraint/role-name size == 0',
    }
  }
}
