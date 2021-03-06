Feature: Fetching SSH Keys
  In order to see a list of all used ssh servers
  As a xing techie
  I want to be able to fetch all authorized keys from remote servers

  Scenario: Fetching all keys from a server
    Given the following keys are on the servers
      | server     | key                                        |
      | preview_server    | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO |
    When I run the fetch_keys command for the server "preview_server"
    Then It should fetch the following keys
      | key                                        |
      | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO |

  Scenario: Fetching all keys from all servers
    Given the following hosts
      """
        13.9.1.41      preview_server
        13.9.1.42      edge_server
        10.53.1.41      production_server
      """
    And the following keys are on the servers
      | server     | key                                                   |
      | 13.9.1.41 | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO            |
      | 13.9.1.41 | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
      | 13.9.1.41 | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local  |
      | 13.9.1.42 | ssh-rsa key3== lee.hambley@xing.com                   |
      | 10.53.1.41 | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
      | 10.53.1.41 | ssh-rsa key5== pascal.friederich@nb-pfriederich.local |
    When I run the fetch_keys command
    Then It should fetch the following keys
        | key                                                   |
        | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO            |
        | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
        | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local  | 
        | ssh-rsa key3== lee.hambley@xing.com                   |
        | ssh-rsa key5== pascal.friederich@nb-pfriederich.local |

  Scenario: Dumping a single servers keys to files
    Given the following keys have been fetched
      | key                                                  |
      | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO           |
      | ssh-rsa key4== abelfernandez@nb-afernandez.local     |
      | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local |
      | ssh-rsa key3== lee.hambley@xing.com                  |
      | ssh-rsa key5== lee.hambley@private                   |
    When I run the dump_keyfiles command
    Then It should generate the following files
      | name                          | key                                                  |
      | abelfernandez.pub             | ssh-rsa key4== abelfernandez@nb-afernandez.local     |
      | adem_deliceoglu.pub           | ssh-rsa key1== Adem.Deliceoglu@PC-ADELICEO           |
      | christian_kvalheim.pub        | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local |
      | lee_hambley.pub               | ssh-rsa key3== lee.hambley@xing.com                  |
      | lee_hambley_2.pub             | ssh-rsa key5== lee.hambley@private                   |
  
  Scenario: Dumping all servers keys to files
    Given the following hosts
      """
        13.9.1.41      preview_server
        10.53.1.42      production_server
      """
    And the following keys are on the servers
      | server     | key                                                   |
      | 13.9.1.41 | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
      | 13.9.1.41 | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local  |
      | 10.53.1.42 | ssh-rsa key4== abel.fernandez@nb-afernandez.local     |
    When I run the fetch_keys command
    And I run the dump_keyfiles command
    Then It should generate the following files
      | name                          | key                                                  |
      | abel_fernandez.pub            | ssh-rsa key4== abel.fernandez@nb-afernandez.local    |
      | christian_kvalheim.pub        | ssh-dss key2== christian.kvalheim@nb-ckvalheim.local |
