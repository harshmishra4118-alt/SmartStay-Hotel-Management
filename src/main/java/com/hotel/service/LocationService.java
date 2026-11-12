package com.hotel.service;

import com.hotel.model.Hotel;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class LocationService {

    private static final double EARTH_RADIUS_KM = 6371.0;
    private static final double AVERAGE_DRIVING_SPEED_KMH = 35.0; // Urban driving speed
    private static final double AVERAGE_WALKING_SPEED_KMH = 4.5;  // Normal walking speed

    /**
     * Calculates the great-circle distance between two GPS coordinates using the Haversine formula.
     *
     * @param lat1 Latitude of point 1 in degrees
     * @param lon1 Longitude of point 1 in degrees
     * @param lat2 Latitude of point 2 in degrees
     * @param lon2 Longitude of point 2 in degrees
     * @return Distance in kilometers
     */
    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double rLat1 = Math.toRadians(lat1);
        double rLat2 = Math.toRadians(lat2);

        double a = Math.sin(dLat / 2.0) * Math.sin(dLat / 2.0) +
                   Math.cos(rLat1) * Math.cos(rLat2) *
                   Math.sin(dLon / 2.0) * Math.sin(dLon / 2.0);

        double c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));
        return EARTH_RADIUS_KM * c;
    }

    /**
     * Enriches a list of hotels with exact calculated distance and travel time estimates
     * from the user's current GPS location.
     */
    public List<Hotel> enrichHotelsWithDistance(List<Hotel> hotels, double userLat, double userLng) {
        for (Hotel hotel : hotels) {
            if (hotel.getLatitude() != null && hotel.getLongitude() != null) {
                double dist = calculateDistance(
                    userLat, userLng,
                    hotel.getLatitude().doubleValue(),
                    hotel.getLongitude().doubleValue()
                );
                hotel.setDistanceKm(dist);
                hotel.setDrivingTimeEstimate(formatDrivingTime(dist));
                hotel.setWalkingTimeEstimate(formatWalkingTime(dist));
            }
        }
        return hotels;
    }

    /**
     * Filters and sorts hotels by distance within a given search radius (in km).
     */
    public List<Hotel> findNearbyHotels(List<Hotel> hotels, double userLat, double userLng, double maxRadiusKm) {
        enrichHotelsWithDistance(hotels, userLat, userLng);
        return hotels.stream()
                .filter(h -> h.getDistanceKm() != null && (maxRadiusKm <= 0 || h.getDistanceKm() <= maxRadiusKm))
                .sorted(Comparator.comparing(Hotel::getDistanceKm))
                .collect(Collectors.toList());
    }

    public String formatDrivingTime(double distanceKm) {
        double hours = distanceKm / AVERAGE_DRIVING_SPEED_KMH;
        int totalMinutes = (int) Math.round(hours * 60.0);
        if (totalMinutes < 1) return "Under 1 min drive";
        if (totalMinutes < 60) return totalMinutes + " mins drive";
        int h = totalMinutes / 60;
        int m = totalMinutes % 60;
        return h + " hr " + (m > 0 ? m + " mins" : "") + " drive";
    }

    public String formatWalkingTime(double distanceKm) {
        if (distanceKm > 15.0) return "Driving recommended";
        double hours = distanceKm / AVERAGE_WALKING_SPEED_KMH;
        int totalMinutes = (int) Math.round(hours * 60.0);
        if (totalMinutes < 1) return "Under 1 min walk";
        if (totalMinutes < 60) return totalMinutes + " mins walk";
        int h = totalMinutes / 60;
        int m = totalMinutes % 60;
        return h + " hr " + (m > 0 ? m + " mins" : "") + " walk";
    }

    public String generateDirectionsUrl(double userLat, double userLng, BigDecimal destLat, BigDecimal destLng) {
        if (destLat == null || destLng == null) return "#";
        return String.format("https://www.google.com/maps/dir/?api=1&origin=%f,%f&destination=%f,%f",
                userLat, userLng, destLat.doubleValue(), destLng.doubleValue());
    }
}

