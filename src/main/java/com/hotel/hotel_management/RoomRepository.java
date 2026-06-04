package com.hotel.hotel_management;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RoomRepository extends MongoRepository<Room, String> {

    // Find all available rooms
    List<Room> findByIsAvailable(boolean isAvailable);

    // Find rooms by type (Single, Double, Suite)
    List<Room> findByRoomType(String roomType);

    // Find room by room number
    Room findByRoomNumber(String roomNumber);

    // Find rooms by floor
    List<Room> findByFloorNumber(int floorNumber);

    // Find available rooms by type
    List<Room> findByRoomTypeAndIsAvailable(String roomType, boolean isAvailable);
}