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

library protocol.common.client_distribution_mode;

class ClientDistributionMode {
  final int index;
  final String _name;
  const ClientDistributionMode(this.index, this._name);
  String toString() => '$ClientDistributionMode.$_name';
  
  static const ClientDistributionMode OFF = const ClientDistributionMode(0, 'OFF');
  static const ClientDistributionMode CONNECTION = const ClientDistributionMode(1, 'CONNECTION');
  static const ClientDistributionMode STATEMENT_ONLY = const ClientDistributionMode(2, 'STATEMENT_ONLY');
  static const ClientDistributionMode STATEMENT_CONNECTION = const ClientDistributionMode(3, 'STATEMENT_CONNECTION');
  
  static const List<ClientDistributionMode> values = const <ClientDistributionMode>[OFF, CONNECTION, STATEMENT_ONLY, STATEMENT_CONNECTION];
}
