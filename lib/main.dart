import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> dataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const String apiKey = 'f9e18be361mshbe2ccdef67ddec4p150708jsn845bd75f0b0a';
    const String host = 'apidojo-yahoo-finance-v1.p.rapidapi.com';
    String path = '/auto-complete?region=US';
    // If a search query is provided, add it to the path
    if (searchController.text.isNotEmpty) {
      path += '&q=${searchController.text}';
    }

    final Dio dio = Dio();

    try {
      final Response<dynamic> response = await dio.get(
        'https://$host$path',
        options: Options(
          headers: {
            'X-RapidAPI-Key': apiKey,
            'X-RapidAPI-Host': host,
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          dataList = response.data['quotes'];
        });
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
        print('Response: ${response.data}');
      }
    } on DioException catch (e) {
      // Handle Dio errors
      print('DioError: $e');
    } catch (error) {
      // Handle other exceptions
      print('Exception: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Fi News",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20,right: 10,top: 10,bottom: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      width: 700,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5), // Adjust the value to control the border radius
                      ),
                      child: TextField(
                        maxLines: 1,
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Enter search query...',
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Adjust the values as needed
                          border: InputBorder.none, // Remove TextField's default border
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Fetch data based on the search query
                      fetchData();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black, // Background color
                      onPrimary: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Border radius
                      ),
                    ),
                    icon: const Icon(Icons.search), // Search icon
                    label: const Text('Search'),
                  ),
                ],
              ),
            ),
            if (dataList.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                    child: Text('Results not found',style: TextStyle(fontSize: 20),),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                height: MediaQuery.of(context).size.height - 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), // Set border color
                  borderRadius: BorderRadius.circular(10), // Set border radius
                ),
                child: ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final item = dataList[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(item['longname'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Symbol: ${item['symbol'] ?? ''}'),
                              Text('Exchange: ${item['exchDisp'] ?? ''}'),
                              Text('Sector: ${item['sector'] ?? ''}'),
                            ],
                          ),
                          onTap: () {
                            print('Item tapped: ${item['longname']}');
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
