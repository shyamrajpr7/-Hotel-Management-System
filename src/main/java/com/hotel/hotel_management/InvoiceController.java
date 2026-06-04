package com.hotel.hotel_management;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Repository
interface InvoiceRepository extends MongoRepository<Invoice, String> {
    List<Invoice> findByGuestId(String guestId);
    List<Invoice> findByBookingId(String bookingId);
    List<Invoice> findByPaymentStatus(String paymentStatus);
}

@RestController
@RequestMapping("/api/invoices")
@CrossOrigin(origins = "*")
class InvoiceController {

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private GuestRepository guestRepository;

    // GET all invoices
    @GetMapping
    public List<Invoice> getAllInvoices() {
        return invoiceRepository.findAll();
    }

    // GET invoice by ID
    @GetMapping("/{id}")
    public Invoice getInvoiceById(@PathVariable String id) {
        return invoiceRepository.findById(id).orElse(null);
    }

    // GET invoices by guest
    @GetMapping("/guest/{guestId}")
    public List<Invoice> getInvoicesByGuest(@PathVariable String guestId) {
        return invoiceRepository.findByGuestId(guestId);
    }

    // POST generate invoice from booking
    @PostMapping("/generate/{bookingId}")
    public Invoice generateInvoice(
            @PathVariable String bookingId,
            @RequestParam(defaultValue = "0") double extraCharges,
            @RequestParam(defaultValue = "CASH") String paymentMethod,
            @RequestParam(defaultValue = "") String notes) {

        // Get booking
        Booking booking = bookingRepository.findById(bookingId).orElse(null);
        if (booking == null) return null;

        // Get guest
        Guest guest = guestRepository.findById(booking.getGuestId()).orElse(null);

        // Calculate amounts
        double roomCharges = booking.getTotalAmount();
        double tax = (roomCharges + extraCharges) * 0.12; // 12% GST
        double total = roomCharges + extraCharges + tax;

        // Build invoice
        Invoice invoice = new Invoice();
        invoice.setBookingId(bookingId);
        invoice.setGuestId(booking.getGuestId());
        invoice.setGuestName(booking.getGuestName());

        if (guest != null) {
            invoice.setGuestPhone(guest.getPhone());
            invoice.setGuestEmail(guest.getEmail());
        }

        invoice.setRoomNumber(booking.getRoomNumber());
        invoice.setRoomType(booking.getRoomType());
        invoice.setCheckInDate(booking.getCheckInDate().toString());
        invoice.setCheckOutDate(booking.getCheckOutDate().toString());
        invoice.setNumberOfNights(booking.getNumberOfNights());

        invoice.setRoomCharges(roomCharges);
        invoice.setExtraCharges(extraCharges);
        invoice.setTaxAmount(Math.round(tax * 100.0) / 100.0);
        invoice.setTotalAmount(Math.round(total * 100.0) / 100.0);
        invoice.setPaidAmount(Math.round(total * 100.0) / 100.0);
        invoice.setBalanceAmount(0);

        invoice.setPaymentMethod(paymentMethod);
        invoice.setPaymentStatus("PAID");
        invoice.setNotes(notes);

        // Generate invoice number like INV-20260313-001
        String invNumber = "INV-" +
            LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) +
            "-" + (invoiceRepository.count() + 1);
        invoice.setInvoiceNumber(invNumber);
        invoice.setGeneratedAt(LocalDateTime.now());

        // Mark booking as paid and checked out
        booking.setPaymentStatus("PAID");
        booking.setStatus("CHECKED_OUT");
        bookingRepository.save(booking);

        return invoiceRepository.save(invoice);
    }

    // PUT update payment
    @PutMapping("/{id}/pay")
    public Invoice markAsPaid(
            @PathVariable String id,
            @RequestParam String paymentMethod) {
        Invoice invoice = invoiceRepository.findById(id).orElse(null);
        if (invoice != null) {
            invoice.setPaymentStatus("PAID");
            invoice.setPaymentMethod(paymentMethod);
            invoice.setPaidAmount(invoice.getTotalAmount());
            invoice.setBalanceAmount(0);
            return invoiceRepository.save(invoice);
        }
        return null;
    }

    // DELETE invoice
    @DeleteMapping("/{id}")
    public String deleteInvoice(@PathVariable String id) {
        invoiceRepository.deleteById(id);
        return "Invoice deleted";
    }
}