package com.hotel.hotel_management;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Document(collection = "invoices")
public class Invoice {

    @Id
    private String id;

    private String bookingId;
    private String guestId;
    private String guestName;
    private String guestPhone;
    private String guestEmail;

    private String roomNumber;
    private String roomType;

    private String checkInDate;
    private String checkOutDate;
    private int numberOfNights;

    private double roomCharges;
    private double extraCharges;
    private double taxAmount;
    private double totalAmount;
    private double paidAmount;
    private double balanceAmount;

    private List<String> extraServices; // e.g. ["Laundry: 200", "Room Service: 500"]

    private String paymentMethod;  // "CASH", "CARD", "UPI"
    private String paymentStatus;  // "PAID", "PARTIAL", "PENDING"

    private String invoiceNumber;
    private LocalDateTime generatedAt;
    private String notes;
}