import 'package:flutter/material.dart';
import 'package:weatherforcasting/View/detail_screen.dart';
import 'package:weatherforcasting/model/india.dart';
import 'package:weatherforcasting/services/utils/states_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class CityList extends StatefulWidget {
  const CityList({super.key});

  @override
  State<CityList> createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  TextEditingController searchController = TextEditingController();
  StatesServices statesServices = StatesServices();
  Future<India>? _indiaFuture;
  List<String> _previousSearches = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousSearches();
  }

  Future<void> _loadPreviousSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _previousSearches = prefs.getStringList('previousSearches') ?? [];
    });
  }

  Future<void> _saveSearch(String cityName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_previousSearches.contains(cityName)) {
      _previousSearches.add(cityName);
      await prefs.setStringList('previousSearches', _previousSearches);
    }
  }

  void _searchCity(String cityName) {
    setState(() {
      if (cityName.isNotEmpty) {
        _indiaFuture = statesServices.indiaApi(cityName.toLowerCase());
      } else {
        _indiaFuture = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                hintText: 'Search with City Name',
                suffixIcon: searchController.text.isEmpty
                    ? const Icon(Icons.search)
                    : GestureDetector(
                        onTap: () {
                          searchController.clear();
                          _searchCity('');
                        },
                        child: const Icon(Icons.clear),
                      ),
              ),
              onChanged: (value) {
                _searchCity(value);
              },
            ),
          ),
          Expanded(
            child: _indiaFuture == null
                ? Center(
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50,),
                        const Padding(
                          padding:  EdgeInsets.all(8.0),
                          child: Text('Enter a city name to search'),
                        ),
                        const SizedBox(height: 50,),
                        const Divider(),
                        const Padding(
                          padding:  EdgeInsets.all(8.0),
                          child: Text("History"),
                        ),
                        if (_previousSearches.isNotEmpty)
                          ..._previousSearches.map((cityName) => ListTile(
                                title: Text(cityName),
                                onTap: () {
                                  searchController.text = cityName;
                                  _searchCity(cityName);
                                },
                              )),
                      ],
                    ),
                  )
                : FutureBuilder<India>(
                    future: _indiaFuture,
                    builder: (context, AsyncSnapshot<India> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Shimmer.fromColors(
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
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('No such city, type complete name '),
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                          child: Text('No data available'),
                        );
                      } else {
                        return InkWell(
                          onTap: () {
                            _saveSearch(snapshot.data!.location!.name.toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  name:snapshot.data!.location!.name.toString(),
                                
                                ),
                              ),
                            );
                          },
                          child: ListView(
                            children: [
                              ListTile(
                                title: Text(snapshot.data!.location!.name.toString()),
                                subtitle: Text(snapshot.data!.location!.region.toString()),
                              ),
                              const Divider(color: Colors.white,),
                            ],
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}