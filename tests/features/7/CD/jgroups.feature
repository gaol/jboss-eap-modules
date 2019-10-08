@jboss-eap-7-tech-preview
Feature: Openshift EAP jgroups
  Scenario: jgroups-encrypt
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | eap_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then container log should contain WFLYSRV0039:
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='encrypt-protocol'][@type='SYM_ENCRYPT']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keystore.jks on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-store
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-alias
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/*[local-name()="key-credential-reference"]/@clear-text
     # https://issues.jboss.org/browse/CLOUD-1192
     # https://issues.jboss.org/browse/CLOUD-1196
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for udp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="stack"][@name="udp"]/*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for tcp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="stack"][@name="tcp"]/*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type

  Scenario: Check jgroups encryption with missing keystore dir creates the location relative to the server dir
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss.server.config.dir on XPath //*[local-name()="key-store"][@name="keystore.jks"]/*[local-name()="file"]/@relative-to

Scenario: Verify configuration and protocol positions jgroups-encrypt, DNS ping protocol and AUTH
    When container is started with env
       | variable                                     | value                                  |
       | JGROUPS_ENCRYPT_SECRET                       | eap_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
       | JGROUPS_PING_PROTOCOL                        | dns.DNS_PING                           |
       | JGROUPS_CLUSTER_PASSWORD                     | P@assw0rd                              |
    Then container log should contain WFLYSRV0039:
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='dns.DNS_PING']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='encrypt-protocol'][@type='SYM_ENCRYPT']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='auth-protocol'][@type='AUTH']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keystore.jks on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-store
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-alias
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/*[local-name()="key-credential-reference"]/@clear-text
     # https://issues.jboss.org/browse/CLOUD-1192
     # https://issues.jboss.org/browse/CLOUD-1196
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for udp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="stack"][@name="udp"]/*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for tcp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="stack"][@name="tcp"]/*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.GMS on XPath //*[local-name()="stack"][@name="udp"]/*[local-name()="auth-protocol"][@type="AUTH"]/following-sibling::*[1]/@type
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.GMS on XPath //*[local-name()="stack"][@name="tcp"]/*[local-name()="auth-protocol"][@type="AUTH"]/following-sibling::*[1]/@type

  Scenario: jgroups-encrypt, galleon
    Given s2i build git://github.com/openshift/openshift-jee-sample from . with env and true using master
    | variable                        | value                                                                                  |
    | GALLEON_PROVISION_LAYERS        | cloud-server,web-clustering            |
    | JGROUPS_ENCRYPT_SECRET          | eap_jgroups_encrypt_secret             |
    | JGROUPS_ENCRYPT_KEYSTORE_DIR    | /etc/jgroups-encrypt-secret-volume     |
    | JGROUPS_ENCRYPT_KEYSTORE        | keystore.jks                           |
    | JGROUPS_ENCRYPT_NAME            | jboss                                  |
    | JGROUPS_ENCRYPT_PASSWORD        | mykeystorepass                         |
   Then container log should contain WFLYSRV0039:
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='encrypt-protocol'][@type='SYM_ENCRYPT']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keystore.jks on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-store
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-alias
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/*[local-name()="key-credential-reference"]/@clear-text
     # https://issues.jboss.org/browse/CLOUD-1192
     # https://issues.jboss.org/browse/CLOUD-1196
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for udp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="stack"][@name="udp"]/*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for tcp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="stack"][@name="tcp"]/*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type

  Scenario: Check jgroups encryption with missing keystore dir creates the location relative to the server, galleon
    Given s2i build git://github.com/openshift/openshift-jee-sample from . with env and true using master
       | variable                                     | value                                  |
       | GALLEON_PROVISION_LAYERS                     | cloud-server,web-clustering            |
       | JGROUPS_ENCRYPT_PROTOCOL                     | SYM_ENCRYPT                            |
       | JGROUPS_ENCRYPT_SECRET                       | jdg_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
    Then XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss.server.config.dir on XPath //*[local-name()="key-store"][@name="keystore.jks"]/*[local-name()="file"]/@relative-to

  Scenario: Verify configuration and protocol positions jgroups-encrypt, DNS ping protocol and AUTH, galleon
    Given s2i build git://github.com/openshift/openshift-jee-sample from . with env and true using master
       | variable                                     | value                                  |
       | GALLEON_PROVISION_LAYERS                     | cloud-server,web-clustering            |
       | JGROUPS_ENCRYPT_SECRET                       | eap_jgroups_encrypt_secret             |
       | JGROUPS_ENCRYPT_KEYSTORE_DIR                 | /etc/jgroups-encrypt-secret-volume     |
       | JGROUPS_ENCRYPT_KEYSTORE                     | keystore.jks                           |
       | JGROUPS_ENCRYPT_NAME                         | jboss                                  |
       | JGROUPS_ENCRYPT_PASSWORD                     | mykeystorepass                         |
       | JGROUPS_PING_PROTOCOL                        | dns.DNS_PING                           |
       | JGROUPS_CLUSTER_PASSWORD                     | P@assw0rd                              |
    Then container log should contain WFLYSRV0039:
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='protocol'][@type='dns.DNS_PING']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='encrypt-protocol'][@type='SYM_ENCRYPT']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should have 2 elements on XPath //*[local-name()='auth-protocol'][@type='AUTH']
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value keystore.jks on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-store
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value jboss on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/@key-alias
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value mykeystorepass on XPath //*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/*[local-name()="key-credential-reference"]/@clear-text
     # https://issues.jboss.org/browse/CLOUD-1192
     # https://issues.jboss.org/browse/CLOUD-1196
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for udp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="stack"][@name="udp"]/*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type
     # Make sure the SYM_ENCRYPT protocol is specified before pbcast.NAKACK for tcp stack
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.NAKACK2 on XPath //*[local-name()="stack"][@name="tcp"]/*[local-name()="encrypt-protocol"][@type="SYM_ENCRYPT"]/following-sibling::*[1]/@type
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.GMS on XPath //*[local-name()="stack"][@name="udp"]/*[local-name()="auth-protocol"][@type="AUTH"]/following-sibling::*[1]/@type
     And XML file /opt/eap/standalone/configuration/standalone-openshift.xml should contain value pbcast.GMS on XPath //*[local-name()="stack"][@name="tcp"]/*[local-name()="auth-protocol"][@type="AUTH"]/following-sibling::*[1]/@type
