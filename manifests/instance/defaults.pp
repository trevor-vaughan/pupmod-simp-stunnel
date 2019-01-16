# Defaults that can be set for all `stunnel::instance` defined types
#
# This allows users to modify prameters on all defined `stunnel::instance`
#
# @param name [String]
#   The name of the stunnel process.
#
# @param trusted_nets
#   Set this if you don't want to allow all IP addresses to access this
#   connection
#
#   * This only makes sense for servers
#
# @param haveged
#   Include ``haveged`` support when setting up stunnel (highly recommended)
#
# @param firewall
#   Include the SIMP ``iptables`` module to manage the firewall
#
# @param tcpwrappers
#   Include the SIMP ``tcpwrappers`` module to manage tcpwrappers
#
# @param pki
#   * If ``simp``, include SIMP's ``pki`` module and use ``pki::copy`` to
#     manage application certs in ``/etc/pki/simp_apps/stunnel/x509``
#   * If ``true``, do *not* include SIMP's pki module, but still use
#     ``pki::copy`` to manage certs in ``/etc/pki/simp_apps/stunnel/x509``
#   * If ``false``, do not include SIMP's pki module and do not use
#     ``pki::copy`` to manage certs.  You will need to appropriately assign a
#     subset of:
#       * app_pki_dir
#       * app_pki_key
#       * app_pki_cert
#       * app_pki_ca_dir
#
# @param app_pki_external_source
#   * If pki = ``simp`` or ``true``, this is the directory from which certs
#     will be copied, via ``pki::copy``
#
#   * If pki = ``false``, this variable has no effect
#
# @param fips
#   Set the ``fips`` global option
#
#   * We don't enable FIPS mode by default since we want to be able to use
#     TLS1.2
#
#   * **NOTE:** This has no effect on EL < 7 due to stunnel not accepting the
#     fips option in that version of stunnel
#
# @param openssl_cipher_suite
#   OpenSSL compatible array of ciphers to allow on the system
#
# @param ssl_version
#   Dictate the SSL version that can be used on the system
#
#   * This default, combined with the default ``$ciphers``, will only negotiate
#     at ``TLSv1.1`` or higher
#
# @param options
#   The OpenSSL library options
#
# @param uid
#   The user id of the stunnel user
#
# @param gid
#   The group id of the stunnel group
#
# All other configuration options can be found in the stunnel man pages
# @see stunnel.conf(5)
# @see stunnel.conf(8)
#
# @param compression
# @param curve
# @param delay
# @param egd
# @param engine
# @param engine_ctrl
# @param engine_num
# @param exec
# @param execargs
# @param failover
# @param local
# @param ocsp
# @param ocsp_flags
# @param renegotiation
# @param reset
# @param retry
# @param rnd_bytes
# @param rnd_overwrite
# @param session_cache_size
# @param session_cache_timeout
# @param setuid
# @param setgid
# @param stack
# @param stunnel_debug
# @param syslog
# @param timeout_busy
# @param timeout_close
# @param timeout_connect
# @param timeout_idle
# @param verify
#
# @author https://github.com/simp/pupmod-simp-stunnel/graphs/contributors
#
class stunnel::instance::defaults(
  Stunnel::Connect                            $connect,
  Variant[Simplib::Port, Simplib::Host::Port] $accept,

  Simplib::Netlist                            $trusted_nets            = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1'] }),
  Boolean                                     $firewall                = simplib::lookup('simp_options::firewall', { 'default_value' => false }),
  Boolean                                     $haveged                 = simplib::lookup('simp_options::haveged', { 'default_value' => true }),
  Boolean                                     $tcpwrappers             = simplib::lookup('simp_options::tcpwrappers', { 'default_value' => false }),
  Variant[Enum['simp'],Boolean]               $pki                     = simplib::lookup('simp_options::pki', { 'default_value' => false }),
  String                                      $app_pki_external_source = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509' }),
  Optional[Enum['zlib','rle']]                $compression             = undef,
  Optional[String]                            $curve                   = undef,
  Boolean                                     $delay                   = false,
  Optional[String]                            $egd                     = undef,
  String                                      $engine                  = 'auto',
  Optional[String]                            $engine_ctrl             = undef,
  Optional[Integer]                           $engine_num              = undef,
  Optional[String]                            $exec                    = undef,
  Array[String]                               $execargs                = [],
  Enum['rr','prio']                           $failover                = 'rr',
  Boolean                                     $fips                    = simplib::lookup('simp_options::fips', { 'default_value' => pick($facts['fips_enabled'], false) }),
  Optional[String]                            $local                   = undef,
  Optional[Simplib::URI]                      $ocsp                    = undef,
  Stunnel::OcspFlags                          $ocsp_flags              = [],
  Array[String]                               $openssl_cipher_suite    = ['HIGH','-SSLv2'],
  Array[String]                               $options                 = [],
  Boolean                                     $renegotiation           = true,
  Boolean                                     $reset                   = true,
  Boolean                                     $retry                   = false,
  Optional[Integer]                           $rnd_bytes               = undef,
  Boolean                                     $rnd_overwrite           = false,
  Optional[Integer]                           $session_cache_size      = undef,
  Optional[Integer]                           $session_cache_timeout   = undef,
  String                                      $setuid                  = 'stunnel',
  String                                      $setgid                  = 'stunnel',
  Integer                                     $uid                     = 600,
  Integer                                     $gid                     = $uid,
  Optional[String]                            $ssl_version             = undef,
  Optional[Integer]                           $stack                   = undef,
  String                                      $stunnel_debug           = 'err',
  Boolean                                     $syslog                  = simplib::lookup('simp_options::syslog', { 'default_value' => false }),
  Optional[Integer]                           $timeout_busy            = undef,
  Optional[Integer]                           $timeout_close           = undef,
  Optional[Integer]                           $timeout_connect         = undef,
  Optional[Integer]                           $timeout_idle            = undef,
  Integer                                     $verify                  = 2
){
  assert_private()

  if $haveged { include '::haveged' }

  ensure_resource('stunnel::account', $setuid,
    {
      'groupname' => $setgid,
      'uid'       => $uid,
      'gid'       => $gid
    }
  )
}
