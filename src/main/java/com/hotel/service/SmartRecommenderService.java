package com.hotel.service;

import com.hotel.dao.RoomDAO;
import com.hotel.model.Room;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Pure Java Rule-Based Room Recommendation Engine.
 * Implements deterministic scoring without Python, ML, or external AI APIs.
 */
public class SmartRecommenderService {

    private final RoomDAO roomDAO = new RoomDAO();

    public static class ScoredRecommendation implements Comparable<ScoredRecommendation> {
        private Room room;
        private double score;
        private int matchPercent;
        private String rationale;

        public ScoredRecommendation(Room room, double score, int matchPercent, String rationale) {
            this.room = room;
            this.score = score;
            this.matchPercent = matchPercent;
            this.rationale = rationale;
        }

        public Room getRoom() { return room; }
        public double getScore() { return score; }
        public int getMatchPercent() { return matchPercent; }
        public String getRationale() { return rationale; }

        @Override
        public int compareTo(ScoredRecommendation other) {
            return Double.compare(other.score, this.score); // Descending
        }
    }

    public List<ScoredRecommendation> getRecommendations(int guests, BigDecimal maxBudget,
                                                         List<String> requestedAmenities,
                                                         Room.RoomType preferredType,
                                                         LocalDate checkIn, LocalDate checkOut,
                                                         int limit) throws SQLException {

        List<Room> candidates = roomDAO.searchAvailableRooms(checkIn, checkOut, null, null, null);
        if (candidates.isEmpty()) {
            return Collections.emptyList();
        }

        List<ScoredRecommendation> scoredList = new ArrayList<>();

        for (Room room : candidates) {
            // Disqualify if room capacity cannot fit the guests
            if (guests > 0 && room.getCapacity() < guests) {
                continue;
            }

            double capacityScore = 0.0;
            if (guests > 0) {
                int diff = room.getCapacity() - guests;
                if (diff == 0) {
                    capacityScore = 30.0; // Perfect fit
                } else if (diff == 1) {
                    capacityScore = 25.0; // Comfortable fit
                } else {
                    capacityScore = Math.max(10.0, 30.0 - (diff * 5.0));
                }
            } else {
                capacityScore = 20.0;
            }

            // Budget scoring (max 30 pts)
            double budgetScore = 20.0;
            if (maxBudget != null && maxBudget.compareTo(BigDecimal.ZERO) > 0) {
                if (room.getPricePerNight().compareTo(maxBudget) <= 0) {
                    // Under budget: give high points
                    double ratio = room.getPricePerNight().doubleValue() / maxBudget.doubleValue();
                    budgetScore = 25.0 + (ratio * 5.0); // 25 to 30 pts
                } else {
                    // Over budget: penalize
                    double overRatio = (room.getPricePerNight().doubleValue() - maxBudget.doubleValue()) / maxBudget.doubleValue();
                    budgetScore = Math.max(0.0, 20.0 - (overRatio * 25.0));
                }
            }

            // Amenity matching (max 25 pts)
            double amenityScore = 10.0;
            List<String> matchedAmenities = new ArrayList<>();
            if (requestedAmenities != null && !requestedAmenities.isEmpty()) {
                String roomAmenitiesLower = room.getAmenities() != null ? room.getAmenities().toLowerCase() : "";
                int matches = 0;
                for (String req : requestedAmenities) {
                    if (req != null && !req.trim().isEmpty() && roomAmenitiesLower.contains(req.toLowerCase().trim())) {
                        matches++;
                        matchedAmenities.add(req.trim());
                    }
                }
                amenityScore = ((double) matches / requestedAmenities.size()) * 25.0;
            }

            // Preferred type matching (max 15 pts)
            double typeScore = 5.0;
            if (preferredType != null) {
                if (room.getRoomType() == preferredType) {
                    typeScore = 15.0;
                }
            }

            double totalScore = capacityScore + budgetScore + amenityScore + typeScore;
            int matchPercent = (int) Math.min(100, Math.round(totalScore));

            // Generate deterministic rationale
            StringBuilder rationale = new StringBuilder();
            if (guests > 0 && room.getCapacity() == guests) {
                rationale.append("Exact capacity fit for ").append(guests).append(" guests. ");
            } else if (guests > 0) {
                rationale.append("Comfortable capacity for ").append(room.getCapacity()).append(" guests. ");
            }

            if (maxBudget != null && room.getPricePerNight().compareTo(maxBudget) <= 0) {
                rationale.append("Within your budget. ");
            }
            if (!matchedAmenities.isEmpty()) {
                rationale.append("Features requested: ").append(String.join(", ", matchedAmenities)).append(". ");
            }
            if (preferredType != null && room.getRoomType() == preferredType) {
                rationale.append("Matches preferred ").append(preferredType.getDisplayName()).append(". ");
            }

            scoredList.add(new ScoredRecommendation(room, totalScore, matchPercent, rationale.toString().trim()));
        }

        Collections.sort(scoredList);
        if (scoredList.size() > limit) {
            return scoredList.subList(0, limit);
        }
        return scoredList;
    }
}
