import 'package:flutter/material.dart';
import '../../domain/entities/room_message.dart';

class ProposalCard extends StatelessWidget {
  final RoomMessage message;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ProposalCard({
    super.key,
    required this.message,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = message.proposalStatus == ProposalStatus.pending;
    final bool isApproved = message.proposalStatus == ProposalStatus.approved;
    final bool isRejected = message.proposalStatus == ProposalStatus.rejected;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber[900]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved ? Colors.green.withOpacity(0.5) 
                 : isRejected ? Colors.red.withOpacity(0.5)
                 : Colors.amber.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Text(
                  'AI Proposed Post',
                  style: TextStyle(
                    color: Colors.amber[100],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (isApproved)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16)
                else if (isRejected)
                  const Icon(Icons.cancel, color: Colors.red, size: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              message.content,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ),
          if (isPending)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Approve & Post'),
                    ),
                  ),
                ],
              ),
            ),
          if (isApproved || isRejected)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                isApproved ? 'Status: Approved' : 'Status: Rejected',
                style: TextStyle(
                  color: isApproved ? Colors.green : Colors.red,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
