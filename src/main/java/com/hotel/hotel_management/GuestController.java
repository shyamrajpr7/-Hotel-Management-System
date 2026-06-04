package com.hotel.hotel_management;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/guests")
@CrossOrigin(origins = "*")
public class GuestController {

    @Autowired
    private GuestRepository guestRepository;

    // GET all guests
    @GetMapping
    public List<Guest> getAllGuests() {
        return guestRepository.findAll();
    }

    // GET guest by ID
    @GetMapping("/{id}")
    public Guest getGuestById(@PathVariable String id) {
        return guestRepository.findById(id).orElse(null);
    }

    // GET guest by phone
    @GetMapping("/phone/{phone}")
    public Guest getGuestByPhone(@PathVariable String phone) {
        return guestRepository.findByPhone(phone);
    }

    // GET search guest by name
    @GetMapping("/search/{name}")
    public List<Guest> searchGuests(@PathVariable String name) {
        return guestRepository.findByFirstNameContainingIgnoreCase(name);
    }

    // POST add new guest
    @PostMapping
    public Guest addGuest(@RequestBody Guest guest) {
        guest.setCreatedAt(LocalDateTime.now());
        return guestRepository.save(guest);
    }

    // PUT update guest
    @PutMapping("/{id}")
    public Guest updateGuest(@PathVariable String id, @RequestBody Guest guest) {
        guest.setId(id);
        return guestRepository.save(guest);
    }

    // DELETE guest
    @DeleteMapping("/{id}")
    public String deleteGuest(@PathVariable String id) {
        guestRepository.deleteById(id);
        return "Guest deleted successfully";
    }
}