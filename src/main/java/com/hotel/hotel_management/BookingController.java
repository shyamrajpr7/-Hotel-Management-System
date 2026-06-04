package com.hotel.hotel_management;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@RestController
@RequestMapping("/api/bookings")
@CrossOrigin(origins = "*")
public class BookingController {

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private RoomRepository roomRepository;

    @Autowired
    private GuestRepository guestRepository;

    // GET all bookings
    @GetMapping
    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }

    // GET bookings by guest
    @GetMapping("/guest/{guestId}")
    public List<Booking> getBookingsByGuest(@PathVariable String guestId) {
        return bookingRepository.findByGuestId(guestId);
    }

    // GET bookings by status
    @GetMapping("/status/{status}")
    public List<Booking> getBookingsByStatus(@PathVariable String status) {
        return bookingRepository.findByStatus(status);
    }

    // POST create new booking
    @PostMapping
    public Booking createBooking(@RequestBody Booking booking) {

        // Get guest details
        Guest guest = guestRepository.findById(booking.getGuestId()).orElse(null);
        if (guest != null) {
            booking.setGuestName(guest.getFirstName() + " " + guest.getLastName());
        }

        // Get room details
        Room room = roomRepository.findById(booking.getRoomId()).orElse(null);
        if (room != null) {
            booking.setRoomNumber(room.getRoomNumber());
            booking.setRoomType(room.getRoomType());
            booking.setPricePerNight(room.getPricePerNight());

            // Calculate nights and total
            long nights = ChronoUnit.DAYS.between(
                booking.getCheckInDate(),
                booking.getCheckOutDate()
            );
            booking.setNumberOfNights((int) nights);
            booking.setTotalAmount(room.getPricePerNight() * nights);

            // Mark room as unavailable
            room.setAvailable(false);
            roomRepository.save(room);
        }

        booking.setStatus("CONFIRMED");
        booking.setPaymentStatus("PENDING");
        booking.setBookedAt(LocalDateTime.now());

        return bookingRepository.save(booking);
    }

    // PUT check in
    @PutMapping("/{id}/checkin")
    public Booking checkIn(@PathVariable String id) {
        Booking booking = bookingRepository.findById(id).orElse(null);
        if (booking != null) {
            booking.setStatus("CHECKED_IN");
            return bookingRepository.save(booking);
        }
        return null;
    }

    // PUT check out
    @PutMapping("/{id}/checkout")
    public Booking checkOut(@PathVariable String id) {
        Booking booking = bookingRepository.findById(id).orElse(null);
        if (booking != null) {
            booking.setStatus("CHECKED_OUT");

            // Mark room as available again
            Room room = roomRepository.findById(booking.getRoomId()).orElse(null);
            if (room != null) {
                room.setAvailable(true);
                roomRepository.save(room);
            }
            return bookingRepository.save(booking);
        }
        return null;
    }

    // PUT cancel booking
    @PutMapping("/{id}/cancel")
    public Booking cancelBooking(@PathVariable String id) {
        Booking booking = bookingRepository.findById(id).orElse(null);
        if (booking != null) {
            booking.setStatus("CANCELLED");

            // Free up the room
            Room room = roomRepository.findById(booking.getRoomId()).orElse(null);
            if (room != null) {
                room.setAvailable(true);
                roomRepository.save(room);
            }
            return bookingRepository.save(booking);
        }
        return null;
    }

    // DELETE booking
    @DeleteMapping("/{id}")
    public String deleteBooking(@PathVariable String id) {
        bookingRepository.deleteById(id);
        return "Booking deleted";
    }
}