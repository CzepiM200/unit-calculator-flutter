import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MaterialApp(
    home: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Units calculator'),
          centerTitle: true,
          bottom: TabBar(
            tabs: choices.map<Widget>((Choice choice) {
              return Tab(
                text: choice.title,
                icon: Icon(choice.icon),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: choices.map((Choice choice) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ChoicePage(
                choice: choice,
              ),
            );
          }).toList(),
        ),
      ),
    ),
  ));
}

class Choice {
  const Choice({this.title, this.icon, this.units, this.powers});
  final String title;
  final IconData icon;
  final List<String> units;
  final List<int> powers;
}


const List<String> distanceUnits = <String>[
  'm','dm','cm','mm','µm','nm','pm','fm','am'
];
const List<int> distancePowers = <int>[
  0,-1,-2,-3,-6,-10,-12,-15,-18
];

const List<String> surfaceUnits = <String>[
  'km\u00B2','hm\u00B2/ha','dam\u00B2/a','m\u00B2','dm\u00B2','cm\u00B2','mm\u00B2','µm\u00B2'
];
const List<int> surfacePowers = <int>[
  6,4,2,0,-2,-4,-6,-12
];

const List<String> volumeUnits = <String>[
  'km\u00B3/TL','hm\u00B3/GL','cm\u00B3/ML','m\u00B3','dm\u00B3/L','cm\u00B3/cL','mm\u00B3/mL'
];
const List<int> volumePowers = <int>[
  9,6,3,0,-3,-6,-9
];

const List<Choice> choices = <Choice>[
  Choice(title: "Distance", icon: Icons.all_inclusive_rounded, units: distanceUnits, powers: distancePowers),
  Choice(title: "Surface", icon: Icons.api_rounded, units: surfaceUnits, powers: surfacePowers),
  Choice(title: "Volume", icon: Icons.local_drink, units: volumeUnits, powers: volumePowers),
];

class ChoicePage extends StatefulWidget {
  const ChoicePage({Key key, @required this.choice}) : super(key: key);
  final Choice choice;

  @override
  _ChoicePageState createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {

  int _value = 0;
  int _mainPower = 0;
  String _dropdownValue = '';
  Choice choice;

  final _formKey = GlobalKey<FormState>();

  Widget _buildValueField() {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    if(_dropdownValue.isEmpty)
      _dropdownValue = this.widget.choice.units[0];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    onChanged: (String value) async {
                      if(!value.isEmpty) {
                        int newValue = int.tryParse(value);
                        if(newValue != null) {
                          setState(() {
                            _value = int.tryParse(value);
                          });
                        }
                        else {
                          setState(() {
                            _value = 0;
                          });
                        }
                      }
                      else {
                        setState(() {
                          _value = 0;
                        });
                      }

                    },
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                ),
                DropdownButton<String>(
                  value: _dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.blue),
                  underline: SizedBox(),
                  items: this.widget.choice.units
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropdownValue = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: generateResults(),
          )
        ],
      ),
    );
  }

  List<Widget> generateResults() {
    List<Container> containers = <Container>[];

    int tempPower = 0;
    for(int i=0 ; i < this.widget.choice.units.length ; i++) {
      if(this.widget.choice.units[i] == _dropdownValue){
        tempPower = this.widget.choice.powers[i];
      }
    }

    debugPrint(tempPower.toString());

    for(int i=0 ; i < this.widget.choice.units.length ; i++) {
      containers.add(
        Container(
          margin: EdgeInsets.fromLTRB(5, 15.0, 5, 0),
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Text(
            '${(_value * pow(10, tempPower - this.widget.choice.powers[i])).toStringAsFixed(4)} ${this.widget.choice.units[i]}',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      );
    }
    return containers;
  }
}

