package com.hotel.hotel_management;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BookingRepository extends MongoRepository<Booking, String> {

    List<Booking> findByGuestId(String guestId);
    List<Booking> findByRoomId(String roomId);
    List<Booking> findByStatus(String status);
    List<Booking> findByPaymentStatus(String paymentStatus);
    List<Booking> findByRoomNumber(String roomNumber);
}
