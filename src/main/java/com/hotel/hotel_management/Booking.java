package com.hotel.hotel_management;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Document(collection = "bookings")
public class Booking {

    @Id
    private String id;

    private String guestId;
    private String guestName;
    private String roomId;
    private String roomNumber;
    private String roomType;

    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private int numberOfNights;

    private double pricePerNight;
    private double totalAmount;

    private String status; // "CONFIRMED", "CHECKED_IN", "CHECKED_OUT", "CANCELLED"
    private String paymentStatus; // "PENDING", "PAID"

    private LocalDateTime bookedAt;
    private String specialRequests;
}