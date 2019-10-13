import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

var header = TextStyle(fontSize: 20.0, color: Color(0xde000000), fontWeight: FontWeight.bold);
var nums = Map();
var dates = Map();
var ddates = Map();
List<String> expr = [];
List<String> dexpr = [];
var todo;
var flnp;
var notiDetails;
var id = 0;

_notYetSnack(scaffold) {
  scaffold.showSnackBar(SnackBar(content: Text('Not available yet!')));
}

updateData() async {
  var prefs = await SharedPreferences.getInstance();
  prefs.setStringList('expr', expr);
  prefs.setStringList('dexpr', dexpr);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Debt Counter',
        home: MoneyList(),
        theme: ThemeData(
            primaryColor: Colors.green,
            accentColor: Colors.green,
            cursorColor: Colors.green,
            textSelectionHandleColor: Colors.green,
            textSelectionColor: Colors.green,
            primaryTextTheme: TextTheme(
                title: TextStyle(color: Colors.green)
            ),
            primaryIconTheme: IconThemeData(color: Colors.green)
        )
    );
  }
}

class MoneyListState extends State<MoneyList>{
  @override
  void initState(){
    super.initState();
    _loadData();

    var initSettings = InitializationSettings(
        AndroidInitializationSettings('ic_stat_name'),
        IOSInitializationSettings());
    
    flnp = FlutterLocalNotificationsPlugin();
    flnp.initialize(initSettings);

    notiDetails = NotificationDetails(
      AndroidNotificationDetails(
          'reminder',
          'Reminders',
          'Reminders set by the user',
          sound: 'cash_register',
          color: Colors.green,
      ),
      IOSNotificationDetails()
    );
  }

  _loadData() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      expr = (prefs.getStringList('expr') ?? []);
      print(expr);
      dexpr = (prefs.getStringList('dexpr') ?? []);
    });
  }


  var appBarActions;
  var appBarTitle = Text('Debt Counter');
  var appBarLeading;

  var selected = [];
  var selectMode = false;

  @override
  Widget build(BuildContext context) {
    if (selected.length == 0) {
      appBarActions = [IconButton(icon: Icon(Icons.add, color: Colors.green), onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<String>(
            builder: (context) {
              return AddDialog();
            },
            fullscreenDialog: true
        ));
      })];
    }
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        backgroundColor: Colors.white,
        actions: appBarActions,
        iconTheme: IconThemeData(color: Colors.green),
        leading: appBarLeading,
      ),
      body: Builder(
        builder: (BuildContext context){
          return _showList();
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _showList(){

    _date(d) => int.parse(d.split('/').reversed.join());

    nums.clear();
    dates.clear();
    ddates.clear();

    expr.forEach((e){
      var f = e.split('~|~');
      nums[f[1]] = (nums[f[1]] ?? 0) + double.parse(f[0]);
      if (nums[f[1]] % 1 == 0) {
        nums[f[1]] = nums[f[1]].round();
      }
      if(_date(f[3]) > (_date(dates[f[1]] ?? '0/0/0'))) dates[f[1]] = f[3];
    });

    dexpr.forEach((e){
      var f = e.split('~|~');
      if(nums[f[1]] == null) if(_date(f[3]) > (_date(ddates[f[1]] ?? '0/0/0'))) ddates[f[1]] = f[3];
    });

//    print(expr);
//    print(dexpr);

//    print(nums);
//    print(ddates);

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: nums.length + ddates.length,
      itemBuilder: (context, i) {
        return _buildRow(i, context);
      },
    );
  }

  _exitSelectMode() {
    setState(() {
      selectMode = false;
      selected = [];
      appBarActions = [IconButton(icon: Icon(Icons.add, color: Colors.green), onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<String>(
            builder: (context){
              return AddDialog();
            },
            fullscreenDialog: true
        ));
      })];
      appBarLeading = null;
      appBarTitle = Text('Debt Counter');
    });
  }

  _confirmDialog(context, action) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$action confirmation'),
            content: Text('Are you sure you want to ${action.toLowerCase()} multiple items?'),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('ACCEPT'),
                onPressed: () {
                  switch(action) {
                    case 'Check':
                      var toMove = [];
                      expr.forEach((e){
                        if (selected.contains(e.split('~|~')[1])) {
                          toMove.add(e);
                        }
                      });
                      toMove.forEach((e) {
                        dexpr.add(e);
                        expr.remove(e);
                      });
                      break;

                    case 'Uncheck':
                      var toMove = [];
                      dexpr.forEach((e){
                        if (selected.contains(e.split('~|~')[1])) {
                          toMove.add(e);
                        }
                      });
                      toMove.forEach((e) {
                        expr.add(e);
                        dexpr.remove(e);
                      });
                      break;

                    case 'Delete':
                      var toDelete = [];
                      expr.forEach((e) {if(selected.contains(e.split('~|~')[1])) toDelete.add(e);});
                      toDelete.forEach((e) => expr.remove(e));
                      toDelete = [];
                      dexpr.forEach((e) {if(selected.contains(e.split('~|~')[1])) toDelete.add(e);});
                      toDelete.forEach((e) => dexpr.remove(e));
                      break;

                    default:
                      break;
                  }
                  updateData();
                  _exitSelectMode();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  _editDialog(context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var controller = TextEditingController();
        controller.text = selected[0];
        return AlertDialog(
          title: Text('Edit Item'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('CHANGE'),
              onPressed: () {
                expr.forEach((e) => expr[expr.indexOf(e)] = e.replaceAll(selected[0], controller.text));
                dexpr.forEach((e) => dexpr[dexpr.indexOf(e)] = e.replaceAll(selected[0], controller.text));
                updateData();
                _exitSelectMode();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildRow(i, context){
    var iconEdit = IconButton(icon: Icon(Icons.edit, color: Colors.green,), onPressed: () => _editDialog(context));
    var iconNoti = IconButton(icon: Icon(Icons.notifications, color: Colors.green), onPressed: () => _notYetSnack(Scaffold.of(context)));
    var iconCheck = IconButton(icon: Icon(Icons.check_circle, color: Colors.green,), onPressed: () => _confirmDialog(context, 'Check'));
    var iconUncheck = IconButton(icon: Icon(Icons.check_circle_outline), onPressed: () => _confirmDialog(context, 'Uncheck'));
    var iconDelete = IconButton(icon: Icon(Icons.delete, color: Colors.green), onPressed: () => _confirmDialog(context, 'Delete'));

    var x = 'ERROR';
    var y = 'ERROR';
    if(i < nums.length) {
      x = nums.keys.elementAt(i);
      //print('X: $x');
    } else {
      y = ddates.keys.elementAt(i - nums.length);
      //print('Y: $y');
    }
    return Center(
      child: GestureDetector(
          onTap: (){
            print('tap');
            if (selectMode) {
              if (selected.contains(i < nums.length ? x : y)) {
                selected.remove(i < nums.length ? x : y);
              } else {
                selected.add(i < nums.length ? x : y);
              }
              var checked = false;
              var unchecked = false;
              selected.forEach((e){
                if (ddates.containsKey(e)) {
                  checked = true;
                } else if (nums.containsKey(e)) {
                  unchecked = true;
                }
              });
              setState(() {
                if (selected.length == 0) {
                  _exitSelectMode();
                } else if (selected.length == 1) {
                  appBarTitle = Text(selected[0]);
                  appBarActions = [iconEdit, iconNoti, checked ? iconUncheck : iconCheck, iconDelete];
                } else {
                  appBarTitle = Text('${selected.length} items');
                  if (checked && unchecked) {
                    appBarActions = [iconDelete];
                  } else {
                    appBarActions = [checked ? iconUncheck : iconCheck, iconDelete];
                  }
                }
              });
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    todo = i < nums.length ? x : y;
                    return FullScreen();
                  },
                  fullscreenDialog: true
              ));
            }
          },
          onLongPress: (){
            print('Longpressed');
            setState(() {
              selectMode = true;
              selected = [i < nums.length ? x : y];
              appBarTitle = Text(i < nums.length ? x : y);
              appBarActions = [iconEdit, iconNoti, nums.keys.contains(i < nums.length ? x : y) ? iconCheck : iconUncheck, iconDelete];
              appBarLeading = IconButton(icon: Icon(Icons.arrow_back, color: Colors.green,), onPressed: _exitSelectMode);
            });
          },
          child: Card(
              color: i < nums.length ? Colors.white : Color(0x10000000),
              elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: selected.contains(i < nums.length ? x : y) ? Color(0xe3000000) : Color(0x33000000),
                    width: selected.contains(i < nums.length ? x : y) ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                                flex: 3,
                                child: Text(i < nums.length ? x : y,
                                  style: TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: i < nums.length ? Color(0xDE000000) : Color(0x99000000),
                                  ),)
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Text(i < nums.length ? '${nums[x]}€' : '',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        color: Color('${nums[x]}'[0] == '-' ? 0xffF44336 : 0xff4CAF50),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0
                                    ),
                                  )
                              ),
                            )
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(i < nums.length ? dates[x] : ddates[y],
                              style: TextStyle(color: Color(0x99000000)),
                            )
                        )
                      ],
                    )
                )
            )
        ),
      );
    }
  }

class MoneyList extends StatefulWidget {
  @override
  MoneyListState createState() => new MoneyListState();
}



class AddDialogState extends State<AddDialog>{
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Entry'),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.green),
          actions: <Widget>[
            Builder(
                builder: (context) {
                  return FlatButton(
                      child: Text('SAVE',
                          style: Theme
                              .of(context)
                              .textTheme
                              .subtitle
                              .copyWith(color: Colors.green)),
                      onPressed: () {
                        if (amountController.text.isNotEmpty &&
                            nameController.text.isNotEmpty) {
                          var date = DateTime.now();
                          var sdate = '${date.day}/${date.month}/${date.year}';
                          expr.insert(0,
                              amountController.text + '~|~' +
                                  nameController.text + '~|~' +
                                  descriptionController.text + '~|~' +
                                  sdate);
                          updateData();
                          Navigator.of(context).pop();
                        } else {
                          var snackbar = SnackBar(
                              content: Text('Name and \$ are required'));
                          Scaffold.of(context).showSnackBar(snackbar);
                        }
                      }
                  );
                }
            )
          ],
        ),
        body: Center(
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color(0x33000000),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Flexible(
                                  flex: 3,
                                  child: TextField(
                                    controller: nameController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        labelText: 'Name',
                                        border: OutlineInputBorder()
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: TextField(
                                      controller: amountController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          labelText: '\$',
                                          border: OutlineInputBorder()
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: TextField(
                                controller: descriptionController,
                                maxLines: 3,
                                maxLength: 100,
                                decoration: InputDecoration(
                                    labelText: 'Description',
                                    border: OutlineInputBorder()
                                ),
                              ),
                            )
                          ],
                        )
                    )
                )
            )
        )
    );
  }
}

class AddDialog extends StatefulWidget {
  @override
  createState() => AddDialogState();
}



class InnerDialog extends StatelessWidget{
  var descriptionController = TextEditingController();
  var amountController = TextEditingController();
  String name;

  InnerDialog(name) {
    this.name = name;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Entry',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500
        ),
      ),
      content: Row(
        children: [
          Flexible(
            flex: 3,
            child: TextField(
              controller: descriptionController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Description'
              )
            )
          ),
          Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left:16),
                child: TextField(
                  controller: amountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: '\$'
                  ),
                ),
              )
          )
        ]
      ),
      /*Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Color(0x33000000),
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        child: TextField(
                          controller: descriptionController,
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder()
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: TextField(
                            controller: amountController,
                            decoration: InputDecoration(
                                labelText: '\$',
                                border: OutlineInputBorder()
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text('7/12/2019',
                        style: TextStyle(color: Color(0x99000000))
                    ),
                  )
                ],
              )
          )
      ),*/
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: ()=> Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text('ADD',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () {
            if (amountController.text.isNotEmpty) {
              var date = DateTime.now();
              var sdate = '${date.day}/${date.month}/${date.year}';
              expr.insert(0,
                  amountController.text + '~|~' +
                      name + '~|~' +
                      descriptionController.text + '~|~' +
                      sdate);
              updateData();
              Navigator.of(context).pop();
            } else {
              var snackbar = SnackBar(
                  content: Text('Name and \$ are required'));
              Scaffold.of(context).showSnackBar(snackbar);
            }
          },
        )
      ],
    );
  }
}


enum Action{restore, delete, reminder, repeat}

class FullScreenState extends State<FullScreen>{

  updateData() async {
    var prefs = await SharedPreferences.getInstance();
    setState((){
      prefs.setStringList('expr', expr);
      prefs.setStringList('dexpr', dexpr);
    });
  }

  Future<void> dialog(context, data) async{
    switch(await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {Navigator.pop(context, Action.delete);},
                child: ListTile(
                  leading: Icon(Icons.close),
                  title: Text('Delete entry'),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {Navigator.pop(context, Action.restore);},
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Restore entry'),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {Navigator.pop(context, Action.reminder);},
                child: ListTile(
                  leading: Icon(Icons.notifications_active),
                  title: Text('Add reminder'),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {Navigator.pop(context, Action.repeat);},
                child: ListTile(
                  leading: Icon(Icons.repeat),
                  title: Text('Add automation'),
                ),
              )
            ],
          );
        }
    )) {
      case Action.delete:
        setState(() {
          dexpr.remove(data.join('~|~'));
        });
        updateData();
        break;
      case Action.restore:
        setState(() {
          expr.insert(0, data.join('~|~'));
          dexpr.remove(data.join('~|~'));
        });
        updateData();
        break;
      case Action.reminder:
        print('DATE: ${notificationDialog(context, data)}');
        break;
      default:
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Not available yet!')));
        break;
    }
  }

  _exitSelectMode() {
    setState(() {
      selectMode = false;
      selected = [];
      appBarActions = null;
      appBarLeading = null;
      appBarTitle = Text(todo);
    });
  }

  _confirmDialog(context, action) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$action confirmation'),
            content: Text('Are you sure you want to ${action.toLowerCase()} the selected entries?'),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('ACCEPT'),
                onPressed: () {
                  selected.forEach((f){
                    var prexpr = expr.where((e) => e.split('~|~')[1] == todo).toList()[f];
                    switch(action) {
                      case 'Check':
                        dexpr.add(prexpr);
                        expr.remove(prexpr);
                        break;

                      case 'Uncheck':
                        expr.add(prexpr);
                        dexpr.remove(prexpr);
                        break;

                      case 'Delete':
                        if (expr.contains(prexpr)) {expr.remove(prexpr);}
                        else {dexpr.remove(prexpr);}
                        break;

                      default:
                        break;
                    }
                  });
                  updateData();
                  _exitSelectMode();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  _editDialog(context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var controller = TextEditingController();
        controller.text =  here[selected[0]][2];
        return AlertDialog(
          title: Text('Edit Item'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text('CHANGE'),
              onPressed: () {
                var prexpr = expr.where((e) => e.split('~|~')[1] == todo).toList()[selected[0]];
                var split = prexpr.split("~|~");
                split[2] = controller.text;
                expr[expr.indexOf(prexpr)] = split.join('~|~');
                updateData();
                _exitSelectMode();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
  var appBarActions;
  var appBarTitle = Text(todo);
  var appBarLeading;

  var selected = [];
  var selectMode = false;

  var here;
  var dhere;
  var total;

  @override
  Widget build(BuildContext context) {
    var iconEdit = IconButton(icon: Icon(Icons.edit, color: Colors.green,), onPressed: () => _editDialog(context));
    var iconNoti = IconButton(icon: Icon(Icons.notifications, color: Colors.green), onPressed: () => _notYetSnack(Scaffold.of(context)));
    var iconCheck = IconButton(icon: Icon(Icons.check_circle, color: Colors.green,), onPressed: () => _confirmDialog(context, 'Check'));
    var iconUncheck = IconButton(icon: Icon(Icons.check_circle_outline), onPressed: () => _confirmDialog(context, 'Uncheck'));
    var iconDelete = IconButton(icon: Icon(Icons.delete, color: Colors.green), onPressed: () => _confirmDialog(context, 'Delete'));
    here = [];
    dhere = [];
    total = 0;
    expr.forEach((f){
      var e = f.split('~|~');
      if(e[1] == todo){
        here.add(e);
        total += double.parse(e[0]);
      }
    });

    if (total % 1 == 0) {
      total = total.round();
    }

    dexpr.forEach((f){
      var e = f.split('~|~');
      if(e[1] == todo){
        dhere.add(e);
      }
    });
    return Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          backgroundColor: Colors.white,
          actions: appBarActions,
          iconTheme: IconThemeData(color: Colors.green),
          leading: appBarLeading,
        ),
        body: Stack(
            children: [
              ListView.builder(
                itemCount: here.length + dhere.length + 1,
                itemBuilder: (context, j){
                  if (j == 0){
                    return Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Total:', style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ProductSans'
                            ),),
                            Text('$total€', style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: '$total'[0] == '-' ? Colors.red : Colors.green
                            ),)
                          ],
                        ));
                  } else if(j <= here.length) {
                    var i = j-1;
                    var key = here[i].join('~|~');
                    return Dismissible(
                        key: Key(key),
                        onDismissed: (direction){
                          setState(() {
                            expr.remove(key);
                            dexpr.insert(0,key);
                            updateData();
                          });
                        },
                        child: GestureDetector(
                            onTap: (){
                              print('tapped!');
                              if (selectMode) {
                                if (selected.contains(i)) {
                                  selected.remove(i);
                                } else {
                                  selected.add(i);
                                }
                                var checked = false;
                                var unchecked = false;
                                selected.forEach((e){
                                  if (ddates.containsKey(e)) {
                                    checked = true;
                                  } else if (nums.containsKey(e)) {
                                    unchecked = true;
                                  }
                                });
                                setState(() {
                                  if (selected.length == 0) {
                                    _exitSelectMode();
                                  } else if (selected.length == 1) {
                                    appBarTitle = Text('1 item');
                                    appBarActions = [iconEdit, iconNoti, checked ? iconUncheck : iconCheck, iconDelete];
                                  } else {
                                    appBarTitle = Text('${selected.length} items');
                                    if (checked && unchecked) {
                                      appBarActions = [iconDelete];
                                    } else {
                                      appBarActions = [checked ? iconUncheck : iconCheck, iconDelete];
                                    }
                                  }
                                });
                              }
                            },
                            onLongPress: (){
                              print('Longpressed!');
                              setState(() {
                                selectMode = true;
                                selected = [i];
                                appBarTitle = Text('1 item');
                                appBarActions = [iconEdit, iconNoti, iconCheck, iconDelete];
                                appBarLeading = IconButton(icon: Icon(Icons.arrow_back, color: Colors.green,), onPressed: _exitSelectMode);
                              });
                            },
                            child: Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: selected.contains(i) ? Color(0xe3000000) : Color(0x33000000),
                                    width: selected.contains(i) ? 2.0 : 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: <Widget>[
                                            Flexible(
                                                flex: 3,
                                                child: Text(here[i][2],
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                  ),)
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 16.0),
                                                  child: Text(here[i][0] + '€',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color: Color(
                                                            here[i][0][0] == '-'
                                                                ? 0xffF44336
                                                                : 0xff4CAF50),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18.0
                                                    ),
                                                  )
                                              ),
                                            )
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(here[i][3],
                                              style: TextStyle(
                                                  color: Color(0x99000000)),
                                            )
                                        )
                                      ],
                                    )
                                )
                            )
                        )
                    );
                  } else {
                    try {
                      var i = j - here.length - 1;
                      return GestureDetector(
                          onLongPress: (){
                            dialog(context, dhere[i]);
                          },
                          child: Card(
                              color: Color(0x05000000),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Color(0x33000000),
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                              flex: 3,
                                              child: Text(dhere[i][2],
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Color(0x99000000)
                                                ),)
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 16.0),
                                                child: Text(dhere[i][0] + '€',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color: Color(0x99000000),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18.0
                                                  ),
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(dhere[i][3],
                                            style: TextStyle(
                                                color: Color(0x99000000)),
                                          )
                                      )
                                    ],
                                  )
                              )
                          )
                      );
                    } on Exception catch(e){
                      print('EXCEEEEEPTION: $e');
                    }
                  }
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                  child:  Padding(
                      padding: EdgeInsets.all(16),
                      child: FloatingActionButton(
                        onPressed: () => showDialog(
                            context: context,
                          builder: (context) => InnerDialog(todo)
                        ),
                        child: Icon(Icons.add),
                      )
                  )
              )
            ]
        )
    );
  }
}

class FullScreen extends StatefulWidget {
  @override
  createState() => FullScreenState();
}


notificationDialog(context, d) async {
  TimeOfDay time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 10),
  );

  if (time != null) {
    var now = DateTime.now();
    var dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    await flnp.schedule(
        0,
        int.parse(d[0]) > 0 ? 'Get you money back!' : 'You have to return some money!',
        int.parse(d[0]) > 0 ? '${d[1]} owes you ${d[0]}€' : 'You owe ${d[1]} ${d[0].slice(1)}€',
        dt,
        notiDetails
    );
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Reminder set!')));
  }
}