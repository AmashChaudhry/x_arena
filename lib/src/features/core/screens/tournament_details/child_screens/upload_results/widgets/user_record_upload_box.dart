import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UserRecordUploadBox extends StatefulWidget {
  const UserRecordUploadBox({
    super.key,
    required this.pubgID,
    required this.pubgName,
    required this.tournamentID,
    required this.userID,
    required this.eliminationController,
    required this.rankingController,
    required this.prizes,
    required this.tournamentCollection,
    required this.userCollection,
    required this.tournamentSnapshot,
    required this.userSnapshot,
  });

  final String pubgID;
  final String pubgName;
  final String tournamentID;
  final String userID;
  final TextEditingController eliminationController;
  final TextEditingController rankingController;
  final List<dynamic> prizes;
  final CollectionReference<Map<String, dynamic>> tournamentCollection;
  final CollectionReference<Map<String, dynamic>> userCollection;
  final Map<String, dynamic> tournamentSnapshot;
  final QueryDocumentSnapshot userSnapshot;

  @override
  State<UserRecordUploadBox> createState() => _UserRecordUploadBoxState();
}

class _UserRecordUploadBoxState extends State<UserRecordUploadBox> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${widget.pubgID}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
              Text(
                widget.pubgName,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'RANKING #',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: widget.rankingController,
                maxLength: 3,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  filled: true,
                  isCollapsed: true,
                  counterText: '',
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 0.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 0.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Text(
                'ELIMINATIONS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: widget.eliminationController,
                maxLength: 2,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  filled: true,
                  isCollapsed: true,
                  counterText: '',
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 0.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 0.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        isLoading
            ? TextButton(
                onPressed: () {},
                child: const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ),
              )
            : TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    int prize = 0;
                    if (int.parse(widget.rankingController.text) > 0 && int.parse(widget.rankingController.text) <= widget.prizes.length) {
                      prize = widget.prizes[int.parse(widget.rankingController.text) - 1];
                    }
                    Map<String, String> playerRecord = {
                      'Tournament ID': widget.tournamentID,
                      'Eliminations': widget.eliminationController.text,
                      'Rank': widget.rankingController.text,
                      'Win Prize': prize.toString(),
                    };
                    List<Map<String, String>> playerRecords = [];
                    playerRecords.add(playerRecord);
                    Map<String, String> tournamentRecord = {
                      'Player ID': widget.userID,
                      'Eliminations': widget.eliminationController.text,
                      'Rank': widget.rankingController.text,
                      'Win Prize': prize.toString(),
                    };
                    List<Map<String, String>> tournamentRecords = [];
                    tournamentRecords.add(tournamentRecord);
                    if (widget.tournamentSnapshot.containsKey('Tournament Record')) {
                      List<Map<String, String>> previousTournamentRecord = (widget.tournamentSnapshot['Tournament Record'] as List<dynamic>).map((record) => Map<String, String>.from(record)).toList();
                      final playerRecordIndex = previousTournamentRecord.indexWhere((record) => record['Player ID'] == widget.userID);
                      if (playerRecordIndex != -1) {
                        previousTournamentRecord[playerRecordIndex] = tournamentRecord;
                      } else {
                        previousTournamentRecord.add(tournamentRecord);
                      }
                      await widget.tournamentCollection.doc(widget.tournamentID).update({'Tournament Record': previousTournamentRecord});
                    } else {
                      await widget.tournamentCollection.doc(widget.tournamentID).update({'Tournament Record': tournamentRecords});
                    }
                    final snapshot = await widget.userCollection.doc(widget.userID).get();
                    final userData = snapshot.data() as Map<String, dynamic>;
                    if (userData.containsKey('Played Tournaments')) {
                      List<Map<String, String>> previousPlayerRecord = (widget.userSnapshot['Played Tournaments'] as List<dynamic>).map((record) => Map<String, String>.from(record)).toList();
                      final tournamentRecordIndex = previousPlayerRecord.indexWhere((record) => record['Tournament ID'] == widget.tournamentID);
                      if (tournamentRecordIndex != -1) {
                        previousPlayerRecord[tournamentRecordIndex] = playerRecord;
                      } else {
                        previousPlayerRecord.add(playerRecord);
                      }
                      await widget.userCollection.doc(widget.userID).update({'Played Tournaments': previousPlayerRecord});
                    } else {
                      await widget.userCollection.doc(widget.userID).update({'Played Tournaments': playerRecords});
                    }
                    widget.eliminationController.text = '';
                    widget.rankingController.text = '';
                    setState(() {
                      isLoading = false;
                    });
                    Get.back();
                  }
                },
                child: const Text('Add'),
              ),
      ],
    );
  }
}
