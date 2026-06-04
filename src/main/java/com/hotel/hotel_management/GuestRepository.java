package com.hotel.hotel_management;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface GuestRepository extends MongoRepository<Guest, String> {

    // Find guest by phone number
    Guest findByPhone(String phone);

    // Find guest by name
    List<Guest> findByFirstNameContainingIgnoreCase(String firstName);

    // Find by ID proof number
    Guest findByIdProofNumber(String idProofNumber);
}