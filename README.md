Dart HANA Connector
=======================

Dart HANA connector enables developers writing Dart applications to use SAP HANA as the database. It implements the [HANA SQL Command Network Protocol reference](http://help.sap.com/hana/SAP_HANA_SQL_Command_Network_Protocol_Reference_en.pdf) to communicate with SAP HANA.

* Note that Dart Connector has been developed  with Dart v1.6. You are free to use any Dart version for your application though. We will try to incrementally use the newer version features where it brings better performance or code readability.

Table of Contents
--------------------

* [Using Dart Connector](#using-dart-connector)
* [Establish a database connection](#establish-a-database-connection)
* [Executing SQL statements](#executing-sql-statements)
* [Prepared statements](#prepared-statements)
* [Calling stored procedures](#calling-stored-procedure)
* [Streaming results](#streaming-results)
* [Features yet to be implemented](#features-yet-to-be-implemented)

Using Dart Connector
--------------------

Some SAP HANA resource links to help get started with your own HANA instance:
* [SAP HANA Developer Center](http://go.sap.com/developer/hana.html)
* [SAP Community Network page](http://scn.sap.com/community/developer-center/hana)

To add Dart connector to your Dart project, you simply need to add it as a dependency in the pubspec.yaml file as shown

```yaml
dependencies:
  Connector:
    git: https://github.com/SAP/dart-hana-connector.git
```
and run

```
git config --global http.sslVerify false
```

To pull the newest version of dartconnector run _pub upgrade_ (on your command line or in dart editor under _Tools_)

Establish a Database Connection
--------------------------------

Firstly, you need to create a Client using the `createClient` method, passing in the options like host and port.

Once the client is created, you can open a network connection to the database host using the `connect` method of the client object. You need to pass in the required connect options to this method. It returns a Future object to listen to which returns either the status on success or the error message on failure.


```dart
import 'dart:async';
import "package:Connector/dart_connector.dart";

void main() {
  Map clientOptions = {
    "host": "hostname",
    "port": 12345
  };
  Map connectOptions = {
    "user": "username",
    "password": "password"
  };

  var client = DartConnector.createClient(clientOptions);
  Future f = client.connect(connectOptions);
  f.then((int status) {
    //Authentication successful
  },
  onError : (Error e) {
    print(e);
  });
}
```

[Currently, the only supported authentication method is using username and password.]

Executing SQL statements
--------------------------------

The `exec` method of the Client can be used to directly execute any SQL statement. The SQL command to be executed needs to be passed in as a parameter. The exec method returns a Future object to listen to for results or for any error.

###DDL Statements

For DDL Statements, nothing is returned back as a result.

```dart
Future result = client.exec('CREATE TABLE TEST.SAMPLE (ID INT, NAME VARCHAR(16))');
result.then((var res) {
  print("Table successfully created");
},
onError : (Error e) {
  print(e);
});
```

###DML Statements

Successful execution of DML statements returns a Map with the number of rows affected as the value for the key `rowsAffected`.

```dart
Future result = client.exec("INSERT INTO TEST.SAMPLE VALUES (1, 'JOHN')");
result.then((Map res) {
  print("Rows affected: " + res['rowsAffected'].toString());
},
onError : (Error e) {
  print(e);
});
```

###DQL Statements

When a query is executed using the exec method, all the selected rows are returned as a List with each row represented as a Map within the list. The resultset is closed and even the LOB attributes are completely read and returned as a Uint8List. If you want to stream the entire result or the LOB atribute object, you need to set a special boolean flag which is described later.

```dart
Future result = client.exec("SELECT * FROM TEST.SAMPLE WHERE ID < 10");
result.then((List rows) {
  List<String> names = new List<String>();
  for (int i = 0; i < rows.length; i++) {
    names.add(rows[i]['NAME']);
  }
  print("Result: " + names.toString());
},
onError : (Error e) {
  print(e);
});
```

Prepared Statements
--------------------------------

You can use the  `prepare` method of Client to create a prepared statement. It returns a future which completes with a statement object as the result.
To execute this prepared statement, you need to call the `exec` method on the statement object passing in an array of values for the positional parameters of the statement.
```dart
Future fPrep = client.prepare('INSERT INTO TEST.SAMPLE VALUES (?, ?)');
fPrep.then((statement) {
  Future fExec = statement.exec([2, 'TOM']);
  fExec.then((result) {
    print("Execution successful. Rows affected - " + result['rowsAffected'].toString());
  }, onError: (Error execErr) {
    print("Error executing the prepared statement - " + execErr.toString());
  });
}, onError: (Error prepErr) {
  print("Error creating the prepared statement - " + prepErr.toString());
});
```

Using LOB type and Binary type parameters is a special case and they need to be passed in using one of the following Dart formats:
* BLOB, CLOB, NCLOB, TEXT : Stream, Uint8List, ByteBuffer, List, String
* BINARY                  : ByteBuffer


###Bulk Insert

A prepared statement can be used to insert multiple rows using a single statement. The exec method needs to be called with all the parameter arrays as one whole array.

```dart
Future fPrep = client.prepare('INSERT INTO TEST.SAMPLE VALUES (?, ?)');
fPrep.then((statement) {
  Future fExec = statement.exec([[3, 'BILL'], [4, 'STEVE'], [5, 'LARRY']]);
  fExec.then((result) {
    print("Bulk insert successful!");
  }, onError: (Error execErr) {
    print("Error during bulk insert " + execErr.toString());
  });
}, onError: (Error prepErr) {
  print("Error creating the prepared statement - " + prepErr.toString());
});

```


Calling Stored Procedures
--------------------------------

To call a stored procedure, you can re-use the prepared statement functionality. The 'call' statement is passed in to the prepare method of the client. The main difference for a stored procedure is that for the `exec` method, you pass in a Map of parameters of the stored procedure as the keys and parameter value as the respective values.

The exec method completes with a result list, whose first element is a Map containing the name and value of the scalar output parameters. If there are no scalar parameters, this is returned as an empty map. The list then further contains the resultsets returned by the procedure call, if any.

For example, if you have a stored procedure as shown:
```dart
create procedure SAMPLE_PROC (in a int, in b int, out sum int, out diff int, out res SAMPLETBL, out f DUMMY)
  language sqlscript
  reads sql data as
  begin
    sum := :a + :b;
    diff := :a - :b;
    res = select * from SAMPLETBL;
    f = select * from DUMMY;
  end
```

A call to this procedure using the dart connector is done in the following manner:

```dart
  Future prep = client.prepare('CALL SAMPLE_PROC (?, ?, ?, ?, ?, ?)');
  prep.then((ps){
  
    Future result = ps.exec({'A': 3, 'B': 4});
    result.then((List result){
      Map outputParams = result[0];
      int sum = outputParams['SUM'];
      int diff = outputParams['DIFF'];
      
      List sampleTblResult = result[1];
      List dummyResult = result[2];
      client.close();
    },
    onError: (e){
      print("Error: $e");
    });
  }
```

Streaming results
--------------------------------

If you want to stream the results, you can use the same `exec` function passing in additionally the boolean typed named parameter - `fetchResultForStreaming` as true. When this addtional parameter is passed in as true, the future returns with a ResultSet object.

You can then fetch the result rows as an array based stream from the result set using the method `createArrayStream`. Later, you should close the result set after the stream has completed streaming the result.

```dart
  List result = [];
  Future strFuture = client.exec("SELECT * FROM TEST.EMPLOYEE", 
                  fetchResultForStreaming: true);
  strFuture.then((resultSet) {
    StreamSubscription subscription = resultSet.createArrayStream().listen((data) {
      result.addAll(data);
    }, onError: (error) => print("Errorwhile listening to stream"), onDone: () {
      print("Final result - " + result.toString());
      resultSet.close();
    });
  });

```

### Streaming  LOB type objects

You can stream LOB types passing in parameter 'fetchResultForStreaming' as true to exec method as mentioned above. The array stream returns a Lob object instead of result rows. On the Lob object, you can call the

1. `createReadStream` method to create a readable stream
2. `read` method to read the LOB completely.

Sample code for both scenarios can be seen in the test cases [here](https://github.com/SAP/dart-hana-connector/blob/master/test/datatypes-lob.dart)

Features yet to be implemented
--------------------------------
* Other authentication methods like SAML / Kerberos
* ...