# Product Requirements Document: Room Search & Management App

## Project Overview
A comprehensive mobile application (Flutter) and admin dashboard for finding, booking, and managing rental rooms. The system facilitates interaction between tenants (Users) and landlords, with an administrative layer for moderation and statistics.

---

## PHẦN 1: USER / LANDLORD - Flutter App

### 1. Splash & Auth
*   **Splash Screen:** Branded entry point.
*   **Authentication:** Sign up, Login, Forgot Password.
*   **OAuth Integration:** Social login via Google and Facebook.

### 2. Home & Explore
*   **Featured Rooms:** High-priority listings.
*   **Latest Listings:** Newest rooms added today.
*   **Recently Viewed:** Quick access to history.
*   **Banners:** Dynamic promotional banners.

### 3. Search & Filter
*   **Advanced Filters:** Price range, area (sqm), amenities (Wifi, AC, Parking).
*   **Room Types:** Entire house, mini apartments, shared rooms.
*   **Location-based:** Search near specific schools or landmarks.

### 4. Room Detail
*   **Media:** Image slider/gallery.
*   **Details:** Full description, amenities list, location.
*   **Reporting:** "Report" button for violations.
*   **Social Proof:** Reviews and ratings from previous viewers.

### 5. Google Maps Integration
*   **Map View:** Visualize room location on a map.
*   **Directions:** Real-time navigation from current location to the room.

### 6. Favorites
*   **Wishlist:** Save favorite rooms.
*   **Cloud Sync:** Synchronized via Firebase across devices.

### 7. Booking System
*   **Scheduling:** Select date/time for viewing.
*   **Status Management:** Pending -> Confirmed / Rejected.
*   **History:** View past booking attempts.

### 8. Reviews & Ratings
*   **Feedback Loop:** 1-5 star ratings + text comments after viewing.
*   **Aggregation:** Display average rating on Room Detail screen.

### 9. Real-time Chat
*   **Messaging:** Direct communication between tenants and landlords using Firebase Firestore.

### 10. Notifications
*   **Push Notifications (FCM):** New rooms, booking updates, new messages.

### 11. Profile & Settings
*   **Account Management:** Profile updates, password changes.
*   **UX:** Dark Mode toggle.

### 12. Landlord: Posting (Đăng tin)
*   **Listing Creation:** Title, description, price, photos, address, amenities.
*   **Moderation Flow:** Listings enter a "Pending" state for Admin approval.

### 13. Landlord: Room Management
*   **Inventory Control:** Edit, delete, or update status (Available / Rented / Hidden).

### 14. Landlord: Appointment Management
*   **Scheduling Control:** View booking requests, confirm or reject appointments.

---

## PHẦN 2: ADMIN - Web Dashboard

### 1. Auth
*   **Admin Login:** Secure access for authorized personnel.

### 2. Dashboard
*   **Overview:** KPI cards (Users, Rooms, Pending Approvals, Reports).
*   **Activity Charts:** Monthly activity trends.

### 3. User Management
*   **User Directory:** List of all users.
*   **Permissions:** Role management (User, Landlord, Admin).
*   **Moderation:** Lock/Unlock accounts.

### 4. Room Management
*   **Global Database:** Access to all listings for editing or deletion.

### 5. Approval System
*   **Queue Management:** Review pending listings.
*   **Moderation Actions:** Approve or Reject with feedback.

### 6. Report Management
*   **Violation Handling:** Process reports from users (Warning, Delete, Ban).

### 7. Statistics
*   **Growth Analytics:** Monthly user/listing growth.
*   **Heatmaps:** Areas with high demand.
*   **Top Performers:** Most active landlords.