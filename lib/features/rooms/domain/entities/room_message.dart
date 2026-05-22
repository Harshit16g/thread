import 'package:equatable/equatable.dart';

enum ProposalStatus { pending, approved, rejected }

class RoomMessage extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final bool isProposal;
  final ProposalStatus? proposalStatus;
  final String? approvedBy;
  final DateTime createdAt;

  const RoomMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    this.isProposal = false,
    this.proposalStatus,
    this.approvedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, roomId, senderId, content, isProposal, proposalStatus, approvedBy, createdAt
  ];
}
