import 'dart:core';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:weatherforcasting/model/india.dart';
import 'package:weatherforcasting/services/utils/states_services.dart';
import 'package:shimmer/shimmer.dart';

class DetailScreen extends StatefulWidget {
  
  final String name;

  DetailScreen({
    
    required this.name,

  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  
   final colorList = const <Color>[
    Color.fromRGBO(210, 218, 59, 1),
    Color(0xffde5246),
    Color(0xff4285F4),
    Color.fromARGB(255, 108, 162, 26),
    Color.fromARGB(255, 160, 9, 9),
    Color.fromARGB(255, 211, 5, 177),
  ];
    StatesServices statesServices = StatesServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        actions: [InkWell(onTap: (){setState(() {
          statesServices.indiaApi(widget.name);
        });},child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.refresh),
        ))],
      ),
          body: SingleChildScrollView(
        child: FutureBuilder<India>(
          future: statesServices.indiaApi("india"),
          builder: (context, AsyncSnapshot<India> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade700,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: Column(
                        children: [
                          ListTile(
                            title: Container(
                              width: 100,
                              height: 8.0,
                              color: Colors.white,
                            ),
                            subtitle: Container(
                              width: double.infinity,
                              height: 8.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('No such city, type complete name'),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text('No data available'),
              );
            } else {
              return Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  PieChart(
                    dataMap: {
                      'Carbon Monoxide': double.parse(snapshot.data!.current!.airQuality!.co.toString()),
                      'Nitrogen Dioxide': double.parse(snapshot.data!.current!.airQuality!.no2.toString()),
                      'Ozone': double.parse(snapshot.data!.current!.airQuality!.o3.toString()),
                      'Sulfur Dioxide': double.parse(snapshot.data!.current!.airQuality!.so2.toString()),
                      'Fine Particulate Matter': double.parse(snapshot.data!.current!.airQuality!.pm25.toString()),
                      'Coarse Particulate Matter': double.parse(snapshot.data!.current!.airQuality!.pm10.toString()),
                    },
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: true,
                    ),
                    chartRadius: MediaQuery.of(context).size.width / 3.5,
                    legendOptions: const LegendOptions(
                      legendPosition: LegendPosition.left,
                    ),
                    chartType: ChartType.ring,
                    animationDuration: const Duration(milliseconds: 1200),
                    colorList: colorList,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Center(
                      child: Text(
                        "Last Updated: ${snapshot.data!.location!.localtime.toString()}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          ReusableRow(
                            title: 'Name',
                            value: snapshot.data!.location!.name.toString(),
                          ),
                          ReusableRow(
                            title: 'Region',
                            value: snapshot.data!.location!.region.toString(),
                          ),
                          ReusableRow(
                            title: 'Country',
                            value: snapshot.data!.location!.country.toString(),
                          ),
                          ReusableRow(
                            title: 'Local Time',
                            value: snapshot.data!.location!.localtime.toString(),
                          ),
                          ReusableRow(
                            title: 'Condition',
                            value: snapshot.data!.current!.condition!.text.toString(),
                          ),
                          ReusableRow(
                            title: 'Temperature (°C)',
                            value: snapshot.data!.current!.tempC.toString(),
                          ),
                          ReusableRow(
                            title: 'Temperature (°F)',
                            value: snapshot.data!.current!.tempF.toString(),
                          ),
                          ReusableRow(
                            title: 'Wind Speed (Mph)',
                            value: snapshot.data!.current!.windMph.toString(),
                          ),
                          ReusableRow(
                            title: 'Wind Speed (Kph)',
                            value: snapshot.data!.current!.windKph.toString(),
                          ),
                          ReusableRow(
                            title: 'Wind Direction',
                            value: snapshot.data!.current!.windDir.toString(),
                          ),
                          ReusableRow(
                            title: 'Cloud',
                            value: snapshot.data!.current!.cloud.toString(),
                          ),
                          ReusableRow(
                            title: 'Humidity',
                            value: snapshot.data!.current!.humidity.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class ReusableRow extends StatelessWidget {
  final String title, value;
  ReusableRow({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text(value)],
          ),
          SizedBox(
            height: 5,
          ),
          Divider()
        ],
      ),
    );
  }
}