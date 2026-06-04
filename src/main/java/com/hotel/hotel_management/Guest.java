package com.hotel.hotel_management;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Document(collection = "guests")
public class Guest {

    @Id
    private String id;

    private String firstName;
    private String lastName;
    private String phone;
    private String email;
    private String idProofType;    // "Aadhaar", "Passport", "Driving License"
    private String idProofNumber;
    private String address;
    private LocalDateTime createdAt;
}