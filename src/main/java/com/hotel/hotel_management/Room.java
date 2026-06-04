package com.hotel.hotel_management;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Data;

@Data
@Document(collection = "rooms")
public class Room {

    @Id
    private String id;

    private String roomNumber;    // e.g. "101", "202"
    private String roomType;      // e.g. "Single", "Double", "Suite"
    private double pricePerNight; // e.g. 2500.00
    private boolean isAvailable;  // true = free, false = booked
    private String description;   // e.g. "AC room with sea view"
    private int floorNumber;      // e.g. 1, 2, 3
}