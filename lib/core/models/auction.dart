import 'package:flutter/material.dart';

enum AuctionStatus { active, endingSoon, completed, cancelled }

extension AuctionStatusX on AuctionStatus {
  String get label => switch (this) {
        AuctionStatus.active => 'LIVE AUCTION',
        AuctionStatus.endingSoon => 'ENDING SOON',
        AuctionStatus.completed => 'AUCTION ENDED',
        AuctionStatus.cancelled => 'CANCELLED',
      };

  Color get color => switch (this) {
        AuctionStatus.active => const Color(0xFF10B981),
        AuctionStatus.endingSoon => const Color(0xFFEF4444),
        AuctionStatus.completed => const Color(0xFF6B7280),
        AuctionStatus.cancelled => const Color(0xFF9CA3AF),
      };
}

class AuctionBid {
  final String id;
  final String bidderId;
  final String bidderName;
  final String bidderPhotoUrl;
  final double amount;
  final DateTime timestamp;

  const AuctionBid({
    required this.id,
    required this.bidderId,
    required this.bidderName,
    required this.bidderPhotoUrl,
    required this.amount,
    required this.timestamp,
  });
}

class AuctionItem {
  final String id;
  final String title;
  final String description;
  final String category; // 'Gadgets', 'Time & Service', 'Fashion & Wear', 'Home & Room', 'Experiences'
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final String sellerPhotoUrl;
  final bool sellerVerified;
  final double sellerRating;
  final double basePrice;
  final double currentBid;
  final double? buyItNowPrice;
  final double serviceFeePercent; // e.g. 5.0% platform fee
  final DateTime startTime;
  final DateTime endTime;
  final int totalBids;
  final AuctionStatus status;
  final List<AuctionBid> bidHistory;
  final String area;
  final double distanceKm;
  final bool isVerifiedSellerOnly;
  final String? videoUrl; // Optional video snippet

  const AuctionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhotoUrl,
    required this.sellerVerified,
    required this.sellerRating,
    required this.basePrice,
    required this.currentBid,
    this.buyItNowPrice,
    this.serviceFeePercent = 5.0,
    required this.startTime,
    required this.endTime,
    required this.totalBids,
    required this.status,
    required this.bidHistory,
    required this.area,
    required this.distanceKm,
    this.isVerifiedSellerOnly = true,
    this.videoUrl,
  });

  bool get isEnded =>
      DateTime.now().isAfter(endTime) || status == AuctionStatus.completed;

  Duration get timeRemaining {
    final diff = endTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  double get platformFeeAmount => (currentBid * serviceFeePercent) / 100.0;
  double get totalWinnerCost => currentBid + platformFeeAmount;

  AuctionItem copyWith({
    double? currentBid,
    int? totalBids,
    List<AuctionBid>? bidHistory,
    AuctionStatus? status,
  }) {
    return AuctionItem(
      id: id,
      title: title,
      description: description,
      category: category,
      imageUrl: imageUrl,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhotoUrl: sellerPhotoUrl,
      sellerVerified: sellerVerified,
      sellerRating: sellerRating,
      basePrice: basePrice,
      currentBid: currentBid ?? this.currentBid,
      buyItNowPrice: buyItNowPrice,
      serviceFeePercent: serviceFeePercent,
      startTime: startTime,
      endTime: endTime,
      totalBids: totalBids ?? this.totalBids,
      status: status ?? this.status,
      bidHistory: bidHistory ?? this.bidHistory,
      area: area,
      distanceKm: distanceKm,
      isVerifiedSellerOnly: isVerifiedSellerOnly,
      videoUrl: videoUrl,
    );
  }
}
