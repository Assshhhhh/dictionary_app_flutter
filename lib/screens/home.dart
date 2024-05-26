import 'package:dictionary_app/models/response_model.dart';
import 'package:flutter/material.dart';

import '../api/api.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool inProgress = false;
  ResponseModel? responseModel;
  String no_data_text = "Welcome, Start Searching..";

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
     body: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           _buildSearchWidget(),
           const SizedBox(height: 12),
           if (inProgress)
             const LinearProgressIndicator()
           else if (responseModel!=null)
             Expanded(child: _buildResponseWidget())
           else
             _noDataWidget()
         ],
       ),
     ),
    ));
  }

  _buildSearchWidget() {
    return SearchBar(
      hintText: "Search word here.. ",
      onSubmitted: (value){
        // API Data
        _getMeaningFromAPI(value);
      },
    );
  }

  _buildResponseWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          responseModel!.word!,
          style: TextStyle(
            color: Colors.purple.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        //Text(responseModel!.phonetics as String ),
        Text(
          responseModel!.phonetics!.where((p) => p.text != null).map((p) => p.text).join(", "),
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: ListView.builder(
          itemBuilder: (context, index) {
            return _buildMeaningWidget(responseModel!.meanings![index]);
          },
          itemCount: responseModel!.meanings!.length,

        ))

      ],
    );
  }

  _buildMeaningWidget(Meanings meanings) {

    String definitionList = "";
    meanings.definitions?.forEach((element) {
     int index = meanings.definitions!.indexOf(element);
     definitionList += "\n${index + 1}. ${element.definition}\n";
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meanings.partOfSpeech!,
              style: TextStyle(
                color: Colors.orange.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )
            ),
            const SizedBox(height: 20),
            const Text(
                "Definitions: ",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )
            ),
            Text(definitionList),
            _buildSet("Synonyms", meanings.synonyms),
            _buildSet("Antonyms", meanings.antonyms),
          ],
        ),
      ),
    );
  }

  _buildSet(String title, List<String>? setList) {
    if (setList?.isNotEmpty??false){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
           "$title: ",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(setList!
              .toSet()
              .toString()
              .replaceAll("{", "")
              .replaceAll("}", ""),
          ),
          const SizedBox(height: 10),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  _noDataWidget() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          no_data_text,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }


  _getMeaningFromAPI(String word) async{
    setState(() {
      inProgress = true;
    });
    try{
      responseModel = await API.fetchMeaning(word);
      setState(() {

      });
    } catch (e) {
      responseModel = null;
      no_data_text = "Word not found";
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }

}

