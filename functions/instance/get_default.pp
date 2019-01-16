# Includes the instance defaults and returns the value for the named parameter
#
#
function stunnel::instance::get_default (
  String[1] $var_name
) {

  include stunnel::instance::defaults

  getparam(Class['stunnel::instance::defaults'], $var_name)
}
