import 'package:flutter/material.dart';

class ServiceRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Function(String) onStatusUpdate;

  const ServiceRequestCard({super.key, required this.request, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    final status = request['status'];
    
    if (status == 'PENDING') statusColor = Colors.orange;
    if (status == 'ACCEPTED') statusColor = Colors.blue;
    if (status == 'COMPLETED') statusColor = Colors.green;
    if (status == 'REJECTED') statusColor = Colors.red;

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
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
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
            if (request['scheduled_date'] != null)
               Padding(
                 padding: const EdgeInsets.only(top: 8),
                 child: Text("📅 ${request['scheduled_date']}", style: const TextStyle(color: Colors.white60)),
               ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'PENDING') ...[
                  OutlinedButton(
                    onPressed: () => onStatusUpdate('REJECTED'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Reject"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => onStatusUpdate('ACCEPTED'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text("Accept"),
                  ),
                ],
                if (status == 'ACCEPTED')
                  ElevatedButton(
                    onPressed: () => onStatusUpdate('COMPLETED'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text("Complete Job"),
                  ),
                if (status == 'COMPLETED' || status == 'REJECTED')
                   const Text("Archived", style: TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
