import 'package:weatherforcasting/model/india.dart';
import 'package:weatherforcasting/services/utils/states_services.dart';
import 'package:flutter/material.dart';
import 'package:weatherforcasting/View/citylist.dart';

import 'package:pie_chart/pie_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(duration: const Duration(seconds: 3), vsync: this)
        ..repeat();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  StatesServices statesServices = StatesServices();

  final colorList = const <Color>[
    Color.fromRGBO(210, 218, 59, 1),
    Color(0xffde5246),
    Color(0xff4285F4),
    Color.fromARGB(255, 108, 162, 26),
    Color.fromARGB(255, 160, 9, 9),
    Color.fromARGB(255, 211, 5, 177),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder(
            future: statesServices.indiaApi("india"),
            builder: (context, AsyncSnapshot<India> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Padding(
                        padding:  EdgeInsets.all(12.0),
                        child: Text("Loading"),
                      ),
                    ],
                  ),
                );
              } else {
                return Column(children: [
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  PieChart(
                    dataMap: {
                      'Carbon Monoxide': double.parse(snapshot.data!.current!.airQuality!.co.toString()),
                      'Nitrogen Dioxide': double.parse(snapshot.data!.current!.airQuality!.no2.toString()),
                      'Ozone':
                          double.parse(snapshot.data!.current!.airQuality!.o3.toString()),
                          'Sulfur Dioxide':
                          double.parse(snapshot.data!.current!.airQuality!.so2.toString()),
                          'Fine Particulate Matter':
                          double.parse(snapshot.data!.current!.airQuality!.pm25.toString()),
                          'Coarse Particulate Matter':
                          double.parse(snapshot.data!.current!.airQuality!.pm10.toString()),

                    },
                    chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true, showChartValuesOutside: true),
                    chartRadius: MediaQuery.of(context).size.width / 3.5,
                    legendOptions: const LegendOptions(
                        legendPosition: LegendPosition.left),
                    chartType: ChartType.ring,
                    animationDuration: const Duration(milliseconds: 1200),
                    colorList: colorList,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  Card(
                    child: Column(
                      children: [
                     
                        ListTile(
                            title: const Text('Country'),
                            subtitle:
                                Text(snapshot.data!.location!.country.toString())),
                                ListTile(
                            title: const Text('Region'),
                            subtitle:
                                Text(snapshot.data!.location!.region.toString())),
                                ListTile(
                            title: const Text('Latitude'),
                            subtitle:
                                Text(snapshot.data!.location!.lat.toString())),
                                ListTile(
                            title: const Text('Longitude'),
                            subtitle:
                                Text(snapshot.data!.location!.lon.toString())),
                                
                       
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .05),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CityList()));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * .08,
                      width: MediaQuery.of(context).size.width / 1.5,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 86, 190, 95),
                          borderRadius: BorderRadius.circular(35)),
                      child: const Center(
                          child: Text(
                        'Track Cities',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 25),
                      )),
                    ),
                  )
                ]);
              }
            }),
      ),
    ));
  }
}

class ReusableRow extends StatelessWidget {
  final String title;
  final double value;
  const ReusableRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 5),
      child: Column(children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text(value.toString())]),
        SizedBox(
          height: MediaQuery.of(context).size.height * .02,
        ),
        const Divider()
      ]),
    );
  }
}
