package com.hotel.service;

import com.hotel.dao.HotelDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Hotel;
import com.hotel.model.HotelFacility;
import com.hotel.model.HotelImage;
import com.hotel.model.Room;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class HotelService {

    private static final Logger logger = LoggerFactory.getLogger(HotelService.class);

    private final HotelDAO hotelDAO = new HotelDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final LocationService locationService = new LocationService();

    public Hotel getHotelById(Long id) throws SQLException {
        if (id == null) return null;
        Hotel hotel = hotelDAO.findById(id);
        if (hotel != null) {
            List<Room> rooms = roomDAO.findByHotelId(id);
            hotel.setRooms(rooms);
        }
        return hotel;
    }

    public List<Hotel> getAllActiveHotels() throws SQLException {
        return hotelDAO.findAllActive();
    }

    public List<Hotel> getAllHotels() throws SQLException {
        return hotelDAO.findAll();
    }

    public List<String> getAvailableCities() throws SQLException {
        return hotelDAO.getDistinctCities();
    }

    /**
     * Search hotels with destination / keywords, price range, rating, facilities, and optional GPS distance.
     */
    public List<Hotel> searchHotels(String query, String city, BigDecimal minPrice, BigDecimal maxPrice,
                                    Double minRating, List<String> facilities, String sortBy,
                                    Double userLat, Double userLng) throws SQLException {
        List<Hotel> hotels = hotelDAO.searchHotels(query, city, minPrice, maxPrice, minRating, facilities, sortBy, userLat, userLng);
        if (userLat != null && userLng != null) {
            locationService.enrichHotelsWithDistance(hotels, userLat, userLng);
        }
        return hotels;
    }

    /**
     * Discovers nearby hotels using GPS coordinates and calculates distance using Haversine formula.
     */
    public List<Hotel> getNearbyHotels(double userLat, double userLng, double radiusKm, String sortBy) throws SQLException {
        List<Hotel> nearby = hotelDAO.findNearby(userLat, userLng, radiusKm, sortBy);
        locationService.enrichHotelsWithDistance(nearby, userLat, userLng);
        return nearby;
    }

    /**
     * Retrieves available rooms for a specific hotel filtered by dates, guest capacity, and room type.
     */
    public List<Room> getAvailableRoomsForHotel(Long hotelId, LocalDate checkIn, LocalDate checkOut,
                                                Integer guests, Room.RoomType roomType) throws SQLException {
        if (hotelId == null) return Collections.emptyList();
        return roomDAO.findAvailableByHotel(hotelId, checkIn, checkOut, guests, roomType);
    }

    /**
     * Compares up to 3 hotels side by side across price, rating, distance, facilities, and policies.
     */
    public List<Hotel> compareHotels(List<Long> hotelIds, Double userLat, Double userLng) throws SQLException {
        if (hotelIds == null || hotelIds.isEmpty()) return Collections.emptyList();
        List<Hotel> compareList = new ArrayList<>();
        for (Long id : hotelIds) {
            if (compareList.size() >= 3) break; // Max 3 hotels for side-by-side comparison
            Hotel h = getHotelById(id);
            if (h != null) {
                if (userLat != null && userLng != null) {
                    double dist = locationService.calculateDistance(
                        userLat, userLng,
                        h.getLatitude().doubleValue(),
                        h.getLongitude().doubleValue()
                    );
                    h.setDistanceKm(dist);
                    h.setDrivingTimeEstimate(locationService.formatDrivingTime(dist));
                }
                compareList.add(h);
            }
        }
        return compareList;
    }

    // --- Admin Operations ---

    public Long createHotel(Hotel hotel) throws SQLException {
        return hotelDAO.create(hotel);
    }

    public boolean updateHotel(Hotel hotel) throws SQLException {
        return hotelDAO.update(hotel);
    }

    public boolean deleteHotel(Long id) throws SQLException {
        return hotelDAO.delete(id);
    }

    public Long addHotelImage(HotelImage img) throws SQLException {
        return hotelDAO.addHotelImage(img);
    }

    public boolean deleteHotelImage(Long imageId) throws SQLException {
        return hotelDAO.deleteHotelImage(imageId);
    }

    public boolean setPrimaryHotelImage(Long hotelId, Long imageId) throws SQLException {
        return hotelDAO.setPrimaryHotelImage(hotelId, imageId);
    }

    public List<HotelImage> getHotelImages(Long hotelId) throws SQLException {
        return hotelDAO.getHotelImages(hotelId);
    }

    public Long addHotelFacility(HotelFacility facility) throws SQLException {
        return hotelDAO.addHotelFacility(facility);
    }

    public boolean deleteHotelFacility(Long facilityId) throws SQLException {
        return hotelDAO.deleteHotelFacility(facilityId);
    }

    public List<HotelFacility> getHotelFacilities(Long hotelId) throws SQLException {
        return hotelDAO.getHotelFacilities(hotelId);
    }
}

