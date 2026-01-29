import 'package:flutter/material.dart';

class ServiceRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Function(String) onStatusUpdate;

  const ServiceRequestCard({super.key, required this.request, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (request['status'] == 'PENDING') statusColor = Colors.orange;
    if (request['status'] == 'QUOTED') statusColor = Colors.blue;
    if (request['status'] == 'ACCEPTED') statusColor = Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2C2C2C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request['vehicle'] != null 
                    ? "${request['vehicle']['brand']} ${request['vehicle']['model']}" 
                    : "No Vehicle Info",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(request['status'], style: TextStyle(color: statusColor, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text("Client: ${request['customer']['full_name']}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Text(
              request['description'],
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request['status'] == 'PENDING')
                  ElevatedButton(
                    onPressed: () => onStatusUpdate('QUOTED'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Quote"),
                  ),
                if (request['status'] == 'ACCEPTED')
                  ElevatedButton(
                    onPressed: () => onStatusUpdate('COMPLETED'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Complete"),
                  ),
                 const SizedBox(width: 8),
                 OutlinedButton(onPressed: () {}, child: const Text("View Details")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
