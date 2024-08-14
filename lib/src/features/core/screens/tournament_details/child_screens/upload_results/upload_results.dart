import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/child_screens/upload_results/widgets/user_record_upload_box.dart';

class UploadResults extends StatefulWidget {
  const UploadResults({
    super.key,
    required this.tournamentId,
  });

  final String tournamentId;

  @override
  State<UploadResults> createState() => _UploadResultsState();
}

class _UploadResultsState extends State<UploadResults> {
  String searchQuery = '';

  TextEditingController eliminationController = TextEditingController();
  TextEditingController rankingController = TextEditingController();

  final userCollection = FirebaseFirestore.instance.collection('Users');
  final tournamentCollection = FirebaseFirestore.instance.collection('Tournaments');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Upload Results',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          PopupMenuButton(
            color: const Color(0xFF161616),
            position: PopupMenuPosition.under,
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (value == 'option') {
                setState(() {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFF161616),
                        contentPadding: EdgeInsets.zero,
                        content: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Once the results have been finalized, editing or adding further data should not be allowed.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF161616),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await tournamentCollection.doc(widget.tournamentId).update({'Status': 'Finalized'});
                              Get.back();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text(
                              'Finalize',
                              style: TextStyle(
                                color: Color(0xFF161616),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                });
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'option',
                child: Text(
                  'Finalize Result',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
              decoration: InputDecoration(
                hintText: 'Search...',
                isCollapsed: true,
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.8)),
                prefixIconConstraints: const BoxConstraints(minWidth: 45),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              ),
            ),
          ),
          StreamBuilder(
            stream: tournamentCollection.doc(widget.tournamentId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final tournamentSnapshot = snapshot.data?.data();
                List<dynamic> participants = tournamentSnapshot?['Participants'];
                List<dynamic> prizes = tournamentSnapshot?['Prizes'];
                return participants.isEmpty
                    ? Center(
                        child: Text(
                          'No Participant',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : StreamBuilder(
                        stream: userCollection.where(FieldPath.documentId, whereIn: participants).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<QueryDocumentSnapshot> participantsSnapshot = [
                              for (String id in participants) snapshot.data!.docs.firstWhere((doc) => doc.id == id),
                            ];
                            List<QueryDocumentSnapshot> filteredParticipants = participantsSnapshot.where((userSnapshot) {
                              final fullName = userSnapshot['Full Name'].toString().toLowerCase();
                              final pubgAccount = userSnapshot['PUBG Account'] as Map<String, dynamic>;
                              final pubgName = pubgAccount['PUBG Name'].toString().toLowerCase();
                              final pubgID = pubgAccount['PUBG ID'].toString().toLowerCase();
                              return fullName.contains(searchQuery) || pubgName.contains(searchQuery) || pubgID.contains(searchQuery);
                            }).toList();
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Theme(
                                  data: ThemeData(dividerColor: Colors.white),
                                  child: DataTable(
                                    dataRowMinHeight: 40,
                                    dataRowMaxHeight: 40,
                                    dividerThickness: 0.2,
                                    showBottomBorder: true,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'Username',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PUBG Name',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PUBG ID',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Rank',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Eliminations',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: filteredParticipants.map((userSnapshot) {
                                      Map<String, dynamic> pubgAccount = userSnapshot['PUBG Account'];
                                      String eliminations = '';
                                      String rank = '';
                                      if (tournamentSnapshot!.containsKey('Tournament Record')) {
                                        List<Map<String, String>> previousTournamentRecord = (tournamentSnapshot['Tournament Record'] as List<dynamic>).map((record) => Map<String, String>.from(record)).toList();
                                        final playerRecordIndex = previousTournamentRecord.indexWhere((record) => record['Player ID'] == userSnapshot.id);
                                        if (playerRecordIndex != -1) {
                                          eliminations = previousTournamentRecord[playerRecordIndex]['Eliminations']!;
                                          rank = previousTournamentRecord[playerRecordIndex]['Rank']!;
                                        }
                                      }
                                      return DataRow(
                                        onLongPress: () {
                                          eliminationController.text = eliminations;
                                          rankingController.text = rank;
                                          setState(() {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return UserRecordUploadBox(
                                                  pubgID: pubgAccount['PUBG ID'],
                                                  pubgName: pubgAccount['PUBG Name'],
                                                  tournamentID: widget.tournamentId,
                                                  userID: userSnapshot.id,
                                                  eliminationController: eliminationController,
                                                  rankingController: rankingController,
                                                  prizes: prizes,
                                                  tournamentCollection: tournamentCollection,
                                                  userCollection: userCollection,
                                                  tournamentSnapshot: tournamentSnapshot,
                                                  userSnapshot: userSnapshot,
                                                );
                                              },
                                            );
                                          });
                                        },
                                        cells: [
                                          DataCell(
                                            Text(
                                              userSnapshot['Full Name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              pubgAccount['PUBG Name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              pubgAccount['PUBG ID'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: Text(
                                                rank.isEmpty ? '-' : '#$rank',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: Text(
                                                eliminations.isEmpty ? '-' : eliminations,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            InkWell(
                                              onTap: () {
                                                eliminationController.text = eliminations;
                                                rankingController.text = rank;
                                                setState(() {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext context) {
                                                      return UserRecordUploadBox(
                                                        pubgID: pubgAccount['PUBG ID'],
                                                        pubgName: pubgAccount['PUBG Name'],
                                                        tournamentID: widget.tournamentId,
                                                        userID: userSnapshot.id,
                                                        eliminationController: eliminationController,
                                                        rankingController: rankingController,
                                                        prizes: prizes,
                                                        tournamentCollection: tournamentCollection,
                                                        userCollection: userCollection,
                                                        tournamentSnapshot: tournamentSnapshot,
                                                        userSnapshot: userSnapshot,
                                                      );
                                                    },
                                                  );
                                                });
                                              },
                                              borderRadius: BorderRadius.circular(25),
                                              child: Ink(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(25),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(25),
                                                      ),
                                                      child: const Icon(
                                                        Icons.add,
                                                        size: 15,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    const Text(
                                                      'Add Record',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const Loading();
                          }
                        },
                      );
              } else {
                return const Loading();
              }
            },
          ),
        ],
      ),
    );
  }
}
