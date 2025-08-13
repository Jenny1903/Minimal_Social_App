import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final Timestamp? timestamp;

  const MyListTile({
    super.key,
    required this.title,
    required this.subTitle,
    this.timestamp,
  });

// Function to format timestamp
String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  // Format time as "12:40 PM"
  String time = DateFormat('h:mm a').format(dateTime);

  // Format date as "Dec 25, 2023"
  String date = DateFormat('MMM d, y').format(dateTime);

  return "$date • $time";
}

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20.0 , right: 20 , bottom: 10),
        child: Container(
          decoration : BoxDecoration(color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          ),

          child: ListTile(
            title: Text(title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                if (timestamp != null)
                  Text(
                    formatTimestamp(timestamp!),// Convert timestamp to readable format
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        )
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// class MyListTile extends StatelessWidget {
//   final String title;
//   final String subTitle;
//   final Timestamp? timestamp; // Add this
//
//   const MyListTile({
//     super.key,
//     required this.title,
//     required this.subTitle,
//     this.timestamp, // Add this
//   });
//
//   // Function to format timestamp
//   String formatTimestamp(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//
//     // Format time as "12:40 PM"
//     String time = DateFormat('h:mm a').format(dateTime);
//
//     // Format date as "Dec 25, 2023"
//     String date = DateFormat('MMM d, y').format(dateTime);
//
//     return "$date • $time";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.only(left: 20.0 , right: 20 , bottom: 10),
//         child: Container(
//           decoration : BoxDecoration(
//             color: Theme.of(context).colorScheme.primary,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListTile(
//             title: Text(title),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   subTitle,
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                 ),
//                 if (timestamp != null)
//                   Text(
//                     formatTimestamp(timestamp!),// Convert timestamp to readable format
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.secondary,
//                       fontSize: 12,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         )
//     );
//   }
// }