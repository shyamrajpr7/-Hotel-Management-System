package com.hotel.hotel_management;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/rooms")
@CrossOrigin(origins = "*")
public class RoomController {

    @Autowired
    private RoomRepository roomRepository;

    // GET all rooms
    @GetMapping
    public List<Room> getAllRooms() {
        return roomRepository.findAll();
    }

    // GET available rooms only
    @GetMapping("/available")
    public List<Room> getAvailableRooms() {
        return roomRepository.findByIsAvailable(true);
    }

    // GET rooms by type
    @GetMapping("/type/{roomType}")
    public List<Room> getRoomsByType(@PathVariable String roomType) {
        return roomRepository.findByRoomType(roomType);
    }

    // GET single room by number
    @GetMapping("/{roomNumber}")
    public Room getRoomByNumber(@PathVariable String roomNumber) {
        return roomRepository.findByRoomNumber(roomNumber);
    }

    // POST add new room
    @PostMapping
    public Room addRoom(@RequestBody Room room) {
        room.setAvailable(true);
        return roomRepository.save(room);
    }

    // PUT update room
    @PutMapping("/{id}")
    public Room updateRoom(@PathVariable String id, @RequestBody Room room) {
        room.setId(id);
        return roomRepository.save(room);
    }

    // DELETE room
    @DeleteMapping("/{id}")
    public String deleteRoom(@PathVariable String id) {
        roomRepository.deleteById(id);
        return "Room deleted successfully";
    }

    // PUT mark room unavailable (booked)
    @PutMapping("/{id}/book")
    public Room bookRoom(@PathVariable String id) {
        Room room = roomRepository.findById(id).orElse(null);
        if (room != null) {
            room.setAvailable(false);
            return roomRepository.save(room);
        }
        return null;
    }

    // PUT mark room available (checkout)
    @PutMapping("/{id}/checkout")
    public Room checkoutRoom(@PathVariable String id) {
        Room room = roomRepository.findById(id).orElse(null);
        if (room != null) {
            room.setAvailable(true);
            return roomRepository.save(room);
        }
        return null;
    }
}
