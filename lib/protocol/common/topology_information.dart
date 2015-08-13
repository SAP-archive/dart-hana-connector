/**
Copyright 2015 SAP Labs LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */

library protocol.common.topology_information;

class TopologyInformation {
  static Map<int, String> LOOKUP = new Map<int, String>();
  
  static final HOST_NAME = createEnum('HOST_NAME', 1);
  static final HOST_PORT_NUMBER = createEnum('HOST_PORT_NUMBER', 2);
  static final TENAT_NAME = createEnum('TENAT_NAME', 3);
  static final LOAD_FACTOR = createEnum('LOAD_FACTOR', 4);
  static final VOLUME_ID = createEnum('VOLUME_ID', 5);
  static final IS_MASTER = createEnum('IS_MASTER', 6);
  static final IS_CURRENT_SESSION = createEnum('IS_CURRENT_SESSION', 7);
  static final SERVICE_TYPE = createEnum('SERVICE_TYPE', 8);
  static final NETWORK_DOMAIN = createEnum('NETWORK_DOMAIN', 9);
  static final IS_STANDBY = createEnum('IS_STANDBY', 10);
    
  static final ALL_IP_ADRESSES = createEnum('ALL_IP_ADRESSES', 11);
  static final ALL_HOST_NAMES = createEnum('ALL_HOST_NAMES', 12);
  
  final int value;
  const TopologyInformation._(this.value);
  
  static createEnum(name, val) {
    LOOKUP[val] = name;
    return new TopologyInformation._(val);
  }
}